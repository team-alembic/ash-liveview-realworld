defmodule Realworld.Controller.UserController do
  use Realworld.Controller

  require Logger

  alias Realworld.Support.User

  @public_attr ~w(email username bio image)a

  post "" do
    {:ok, strategy} = AshAuthentication.Info.strategy(User, :password)

    {status, result} =
      with {:ok, data} <- conn |> get_body("user"),
           {:ok, resource} <-
             AshAuthentication.Strategy.action(strategy, :register, data) do
        user = resource |> Map.take(@public_attr)
        user = user |> Map.put(:token, resource.__metadata__.token)

        {:ok, %{user: user}}
      else
        {:error, %Ash.Error.Invalid{} = errors} ->
          result = %{errors: parse_errors(errors)}
          {:unprocessable_entity, result}
      end

    conn
    |> send_json({status, result})
  end

  post "/login" do
    {:ok, strategy} = AshAuthentication.Info.strategy(User, :password)

    {status, result} =
      with {:ok, data} <- conn |> get_body("user"),
           {:ok, resource} <-
             AshAuthentication.Strategy.action(strategy, :sign_in, data) do
        user = resource |> Map.take(@public_attr)
        user = user |> Map.put(:token, resource.__metadata__.token)

        {:ok, %{user: user}}
      else
        {:error, errors} ->
          result = %{errors: parse_errors(errors)}
          {:unprocessable_entity, result}
      end

    conn
    |> send_json({status, result})
  end

  get "" do
    {status, result} =
      with {:ok, resource} <- conn |> get_current_user() do
        resource |> IO.inspect()
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
        resource_updated |> IO.inspect()

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
