defmodule Realworld.Application do
  use Application
  require Logger

  alias Realworld.{Repo, Endpoint}

  @impl true
  def start(_type, _args) do
    port = Application.get_env(:realworld, :port)

    children = [
      Repo,
      {Plug.Cowboy, scheme: :http, plug: Endpoint, options: [port: port]},
      {AshAuthentication.Supervisor, otp_app: :realworld}
    ]

    Logger.info("Running Realworld.Endpoint with cowboy at port #{port}")

    Supervisor.start_link(children, strategy: :one_for_one, name: Realworld.Supervisor)
  end
end
