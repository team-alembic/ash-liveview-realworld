defmodule Realworld.Plug.Auth do
  alias AshAuthentication.{Info, Jwt, TokenResource}
  alias Plug.Conn

  def load_user(conn, otp_app) do
      with "Token "+ token <- conn |> Conn.get_req_header("authorization"),
          {:ok, %{"sub" => subject, "jti" => jti}, resource} <- Jwt.verify(token, otp_app),
           :ok <- validate_token(resource, jti),
           {:ok, user} <- AshAuthentication.subject_to_user(subject, resource),
           {:ok, subject_name} <- Info.authentication_subject_name(resource),
           current_subject_name <- current_subject_name(subject_name) do
        conn
        |> Conn.assign(current_subject_name, user)
      else
        _ -> conn
      end
    end
  end

  defp validate_token(resource, jti) do
    if Info.authentication_tokens_require_token_presence_for_authentication?(resource) do
      with {:ok, token_resource} <- Info.authentication_tokens_token_resource(resource),
           {:ok, [_]} <-
             TokenResource.Actions.get_token(token_resource, %{
               "jti" => jti,
               "purpose" => "user"
             }) do
        :ok
      end
    else
      :ok
    end
  end

  defp current_subject_name(subject_name) when is_atom(subject_name),
    do: String.to_atom("current_#{subject_name}")
end
