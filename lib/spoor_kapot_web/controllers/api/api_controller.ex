defmodule SpoorKapotWeb.ApiController do
  require Logger
  use SpoorKapotWeb, :controller

  def register(conn, params) do
    {:ok, sub} = SpoorKapot.Subscription.new(params)
    SpoorKapot.Subscription.store(sub)
    json(conn, %{})
  end
end
