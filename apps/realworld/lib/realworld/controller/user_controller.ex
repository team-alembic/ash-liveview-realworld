defmodule Realworld.Controller.UserController do
  use Realworld.Controller

  require Logger

  alias Ash.Changeset
  alias Realworld.Support
  alias Realworld.Support.User

  post "" do
    {status, result} =
      with {:ok, data} <- conn |> get_body("user"),
           {:ok, resource} <-
             User |> Changeset.for_create(:registration, data) |> Support.create() do
        user = resource |> Map.take([:email, :token, :username, :bio, :image])

        {:ok, %{user: user}}
      else
        {:error, error} ->
          Logger.warn("User registration fail", error)
          {:unprocessable_entity, error}
      end

    conn
    |> send_json({status, result})
  end
end
