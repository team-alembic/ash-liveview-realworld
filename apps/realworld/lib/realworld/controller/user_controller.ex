defmodule Realworld.Controller.UserController do
  use Realworld.Controller

  require Logger

  alias Realworld.Support.User

  @public_attr ~w(email token username bio image)a

  post "" do
    {:ok, strategy} = AshAuthentication.Info.strategy(User, :password)

    {status, result} =
      with {:ok, data} <- conn |> get_body("user"),
           {:ok, resource} <-
             AshAuthentication.Strategy.action(strategy, :register, data) do
        user = resource |> Map.take(@public_attr)

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
        resource |> IO.inspect()

        user = resource |> Map.take(@public_attr)

        {:ok, %{user: user}}
      else
        {:error, _error} ->
          {:unprocessable_entity, %{errors: %{email: ["e-mail or password invalid"]}}}
      end

    conn
    |> send_json({status, result})
  end
end
