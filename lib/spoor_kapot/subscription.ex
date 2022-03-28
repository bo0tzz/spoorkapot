defmodule SpoorKapot.Subscription do
  defstruct [:endpoint, :keys]

  def new(%{"endpoint" => endpoint, "keys" => %{"p256dh" => p256dh, "auth" => auth}}),
    do:
      {:ok,
       %SpoorKapot.Subscription{
         endpoint: endpoint,
         keys: %{
           p256dh: p256dh,
           auth: auth
         }
       }}

  def new(_), do: :error

  def store(%SpoorKapot.Subscription{endpoint: endpoint} = sub) do
    Pockets.put(:subscriptions, endpoint, sub)
  end
end
