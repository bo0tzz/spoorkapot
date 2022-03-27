defmodule SpoorKapot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    db_file = Application.fetch_env!(:spoor_kapot, :database_file)
    {:ok, :subscriptions} = Pockets.open(:subscriptions, db_file, create?: true)

    children = [
      # Start the Telemetry supervisor
      SpoorKapotWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: SpoorKapot.PubSub},
      # Start the Endpoint (http/https)
      SpoorKapotWeb.Endpoint
      # Start a worker by calling: SpoorKapot.Worker.start_link(arg)
      # {SpoorKapot.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SpoorKapot.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SpoorKapotWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
