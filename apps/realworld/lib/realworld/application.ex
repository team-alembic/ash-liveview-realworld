defmodule Realworld.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the PubSub system
      {Phoenix.PubSub, name: Realworld.PubSub}
      # Start a worker by calling: Realworld.Worker.start_link(arg)
      # {Realworld.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Realworld.Supervisor)
  end
end
