defmodule SpoorKapotWeb.Router do
  use SpoorKapotWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {SpoorKapotWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SpoorKapotWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/api", SpoorKapotWeb do
    pipe_through :api

    post "/register", ApiController, :register
  end
end
