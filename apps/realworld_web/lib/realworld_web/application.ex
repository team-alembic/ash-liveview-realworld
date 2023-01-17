defmodule RealworldWeb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      RealworldWeb.Telemetry,
      # Start the Endpoint (http/https)
      RealworldWeb.Endpoint
      # Start a worker by calling: RealworldWeb.Worker.start_link(arg)
      # {RealworldWeb.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RealworldWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RealworldWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
