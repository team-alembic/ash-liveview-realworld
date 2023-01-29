defmodule Realworld.Endpoint do
  use Plug.Router
  use Plug.ErrorHandler

  alias Realworld.Controller.{UserController, ProfileController}

  plug(Plug.Logger, log: :debug)
  plug(Plug.RequestId)

  plug(:match)
  plug(:dispatch)

  forward("/api/users", to: UserController)
  forward("/api/user", to: ProfileController)

  @impl Plug.ErrorHandler
  def handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack}) do
    conn
    |> send_resp(conn.status, "Something went wrong")
  end
end
