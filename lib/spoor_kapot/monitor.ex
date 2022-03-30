defmodule SpoorKapot.Monitor do
  use Quantum, otp_app: :spoor_kapot
  require Logger

  @known_disruptions_filename "disruptions.bin"

  def run() do
    Logger.info("Running notifications task")
    known_disruptions = load_known_disruptions()
    disruptions = SpoorKapot.NsApi.disruptions()

    case Enum.reject(disruptions, &(&1.id in known_disruptions)) do
      [] ->
        Logger.info("No new disruptions")

      new_disruptions ->
        Logger.info("#{Enum.count(new_disruptions)} new disruptions")

        send_notifications(new_disruptions)

        disruptions
        |> Enum.map(& &1.id)
        |> save_known_disruptions()
    end
  end

  defp send_notifications(disruptions) do
    disruptions =
      Enum.map(disruptions, fn disruption ->
        {disruption.id, disruption.title, MapSet.new(disruption.affected_stations, & &1.code)}
      end)

    sent_notifications =
      Enum.map(SpoorKapot.Subscription.all(), &notify_subscription(&1, disruptions))
      |> Enum.sum()

    Logger.info("Sent #{sent_notifications} notifications")
  end

  defp notify_subscription({subscription_key, subscription}, disruptions) do
    disruptions
    |> Enum.reject(fn {_, _, codes} -> MapSet.disjoint?(codes, subscription.stations) end)
    |> Enum.map(fn {id, title, _} ->
      msg =
        %SpoorKapot.PushMessage{
          title: title,
          url: "https://www.ns.nl/reisinformatie/actuele-situatie-op-het-spoor/detail?id=" <> id
        }
        |> Jason.encode!()

      case WebPushEncryption.send_web_push(msg, subscription.push) do
        {:ok, %{status_code: status}} when status in [200, 201] ->
          :sent

        {:ok, %{status_code: status}} when status in [404, 410] ->
          SpoorKapot.Subscription.delete(subscription_key)
          :deleted

        error ->
          Logger.warning("Unexpected error when sending push message: #{inspect(error)}")
          :error
      end
    end)
    |> Enum.count(&match?(:sent, &1))
  end

  defp load_known_disruptions() do
    with folder <- Application.fetch_env!(:spoor_kapot, :database_folder),
         path <- Path.join(folder, @known_disruptions_filename),
         {:ok, bin} <- File.read(path) do
      :erlang.binary_to_term(bin)
    else
      {:error, :enoent} -> []
    end
  end

  defp save_known_disruptions(disruptions) do
    with folder <- Application.fetch_env!(:spoor_kapot, :database_folder),
         path <- Path.join(folder, @known_disruptions_filename),
         bin <- :erlang.term_to_binary(disruptions) do
      File.write!(path, bin)
    end
  end
end
