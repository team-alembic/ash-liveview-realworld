defmodule Realworld.Controller do
  defmacro __using__(_opts) do
    quote do
      use Plug.Router

      plug(Plug.Parsers,
        parsers: [:urlencoded, :multipart, :json],
        pass: ["*/*"],
        json_decoder: Jason
      )

      plug(:match)
      plug(:dispatch)

      def get_body(conn, attr) do
        %{body_params: params} = conn

        params
        |> Map.get(attr)
        |> case do
          nil -> {:error, :attribute_root_does_not_exist}
          data -> {:ok, data}
        end
      end

      def send_json(conn, {status, result}) do
        json = Jason.encode!(result)

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(status, json)
      end
    end
  end
end
