defmodule Realworld.Endpoint do
  use Plug.Router
  use Plug.ErrorHandler

  plug(Plug.Logger, log: :debug)
  plug(Plug.RequestId)

  forward("/api/users", to: Realworld.Controller.UserController)

  @impl Plug.ErrorHandler
  def handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack}) do
    conn
    |> send_resp(conn.status, "Something went wrong")
  end
end
