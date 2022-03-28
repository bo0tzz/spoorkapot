defmodule SpoorKapot.PushMessage do
  @derive Jason.Encoder
  defstruct [:title, :url]
end
