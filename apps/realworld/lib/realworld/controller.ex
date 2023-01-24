defmodule Realworld.Controller do
  defmacro __using__(opts) do
    quote do
      use Plug.Router

      import Realworld.Plug.Auth

      %{auth?: auth} =
        unquote(opts)
        |> Enum.into(%{auth?: true})

      plug(Plug.Parsers,
        parsers: [:urlencoded, :multipart, :json],
        pass: ["*/*"],
        json_decoder: Jason
      )

      plug(:load_user)

      if auth do
        plug(:require_auth)
      end

      plug(:match)
      plug(:dispatch)

      def get_body(conn, attr) do
        %{body_params: params} = conn

        params
        |> Map.get(attr)
        |> case do
          nil ->
            {:error,
             %Ash.Error.Invalid{
               errors: [
                 %Ash.Error.Changes.InvalidAttribute{
                   field: attr,
                   message: "can't be empty",
                   vars: []
                 }
               ]
             }}

          data ->
            {:ok, data}
        end
      end

      def send_json(conn, {status, result}) do
        json = Jason.encode!(result)

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(status, json)
      end

      def parse_errors(%Ash.Error.Invalid{errors: errors}) do
        errors
        |> Enum.map(fn error ->
          error
          |> case do
            %Ash.Error.Changes.InvalidAttribute{field: field, message: message, vars: _vars} ->
              {field, message}

            %Ash.Error.Changes.Required{field: field} ->
              {field, "must be present"}
          end
        end)
        |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
        |> Enum.map(fn {attr, msgs} -> {attr, Enum.uniq(msgs)} end)
        |> Map.new()
      end

      def parse_errors(%AshAuthentication.Errors.AuthenticationFailed{}),
        do: %{
          email: ["is invalid"],
          password: ["is invalid"]
        }

      def get_current_user(conn) do
        conn.assigns
        |> case do
          %{current_user: user} ->
            {:ok, user}

          _ ->
            {:error, :unauthorized}
        end
      end

      def require_auth(%Plug.Conn{assigns: %{current_user: user}} = conn, _opts)
          when not is_nil(user),
          do: conn

      def require_auth(conn, _opts) do
        error = %{
          errors: %{
            authorization: ["is invalid"]
          }
        }

        conn
        |> send_json({:unauthorized, error})
        |> halt()
      end
    end
  end
end
