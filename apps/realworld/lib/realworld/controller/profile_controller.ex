defmodule Realworld.Controller.ProfileController do
  use Realworld.Controller

  require Logger

  @public_attr ~w(email username bio image)a

  get "" do
    {status, result} =
      with {:ok, resource} <- conn |> get_current_user() do
        user = resource |> Map.take(@public_attr)

        {:ok, %{user: user}}
      else
        {:error, errors} ->
          result = %{errors: parse_errors(errors)}
          {:unprocessable_entity, result}
      end

    conn
    |> send_json({status, result})
  end

  put "" do
    {status, result} =
      with {:ok, data} <- conn |> get_body("user"),
           {:ok, resource} <- conn |> get_current_user(),
           {:ok, resource_updated} <-
             resource
             |> Ash.Changeset.for_update(:update_profile, data)
             |> Realworld.Support.update() do
        user = resource_updated |> Map.take(@public_attr)

        {:ok, %{user: user}}
      else
        {:error, errors} ->
          result = %{errors: parse_errors(errors)}
          {:unprocessable_entity, result}
      end

    conn
    |> send_json({status, result})
  end
end
