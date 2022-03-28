defmodule SpoorKapot.Notifications do
  require Logger

  @known_disruptions_filename "disruptions.bin"

  def send_notifications() do
    known_disruptions = load_known_disruptions()
    disruptions = SpoorKapot.NsApi.disruptions()

    Enum.reject(disruptions, &(&1.id in known_disruptions))
    |> case do
      [] ->
        Logger.info("No new disruptions")

      new_disruptions ->
        Logger.info("#{Enum.count(new_disruptions)} new disruptions")

        disrupted_stations =
          Enum.map(new_disruptions, fn %{id: id, affected_stations: affected_stations} ->
            {id, MapSet.new(affected_stations, & &1.code)}
          end)

        # send notifications
        SpoorKapot.Subscription.all()
        |> Enum.each(fn {_, %{push: push, stations: stations}} ->
          Enum.reject(disrupted_stations, fn {_id, codes} -> MapSet.disjoint?(codes, stations) end)
          |> Enum.each(fn {id, _codes} ->
            Logger.info("Sending notification for ID #{id}")

            msg =
              %SpoorKapot.PushMessage{
                title: id,
                url:
                  "https://www.ns.nl/reisinformatie/actuele-situatie-op-het-spoor/detail?id=" <>
                    id
              }
              |> Jason.encode!()

            WebPushEncryption.send_web_push(msg, push)
          end)
        end)

        disruptions
        |> Enum.map(& &1.id)
        |> save_known_disruptions()
    end
  end

  def load_known_disruptions() do
    with folder <- Application.fetch_env!(:spoor_kapot, :database_folder),
         path <- Path.join(folder, @known_disruptions_filename),
         {:ok, bin} <- File.read(path) do
      bin_to_term(bin)
    else
      _ -> []
    end
  end

  def save_known_disruptions(disruptions) do
    with folder <- Application.fetch_env!(:spoor_kapot, :database_folder),
         path <- Path.join(folder, @known_disruptions_filename),
         bin <- :erlang.term_to_binary(disruptions) do
      File.write!(path, bin)
    end
  end

  def bin_to_term(bin) do
    try do
      :erlang.binary_to_term(bin)
    rescue
      _ -> []
    end
  end
end
