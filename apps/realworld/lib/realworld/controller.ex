defmodule Realworld.Controller do
  defmacro __using__(_opts) do
    quote do
      use Plug.Router

      plug(Plug.Parsers,
        parsers: [:urlencoded, :multipart, :json],
        pass: ["*/*"],
        json_decoder: Jason
      )

      plug(:load_user)
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

      def get_current_user(conn) do
        conn.assigns
        |> IO.inspect()
        |> case do
          %{user: user} ->
            {:ok, user}

          _ ->
            {:error, :unauthorized}
        end
      end
    end
  end
end
