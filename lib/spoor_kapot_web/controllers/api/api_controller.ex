defmodule SpoorKapotWeb.ApiController do
  require Logger
  use SpoorKapotWeb, :controller

  def register(conn, params) do
    sub = SpoorKapot.Subscription.new(params)
    json(conn, %{})
  end
end
