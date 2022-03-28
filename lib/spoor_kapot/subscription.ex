defmodule SpoorKapot.Subscription do
  defstruct [:stations, :push]

  def new(%{
        "stations" => stations,
        "subscription" => %{
          "endpoint" => endpoint,
          "keys" => %{"p256dh" => p256dh, "auth" => auth}
        }
      }),
      do:
        {:ok,
         %SpoorKapot.Subscription{
           stations: MapSet.new(stations),
           push: %{
             endpoint: endpoint,
             keys: %{
               p256dh: p256dh,
               auth: auth
             }
           }
         }}

  def new(_), do: :error

  def store(%SpoorKapot.Subscription{push: %{endpoint: endpoint}} = sub) do
    Pockets.put(:subscriptions, endpoint, sub)
  end

  def all() do
    Pockets.to_stream(:subscriptions)
  end
end
