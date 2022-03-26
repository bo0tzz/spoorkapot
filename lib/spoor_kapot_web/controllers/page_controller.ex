defmodule SpoorKapotWeb.PageController do
  use SpoorKapotWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
