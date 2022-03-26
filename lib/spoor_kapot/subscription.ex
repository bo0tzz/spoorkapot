defmodule SpoorKapot.Subscription do
  defstruct [:endpoint, :keys]

  def new(%{"endpoint" => endpoint, "keys" => %{"p256dh" => p256dh, "auth" => auth}}),
    do: %SpoorKapot.Subscription{
      endpoint: endpoint,
      keys: %{
        p256dh: p256dh,
        auth: auth
      }
    }

  def new(_), do: :error

  def send_message(subscription, message),
    do: WebPushEncryption.send_web_push(message, subscription)
end
