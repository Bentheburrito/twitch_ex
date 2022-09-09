defmodule TwitchEx.OAuth do
  @moduledoc """
  Custom Twitch OAuth2/Client Credentials Grant Flow solution.

  https://dev.twitch.tv/docs/authentication/getting-tokens-oauth/#client-credentials-grant-flow
  """

  require Logger

  # @authorize_url "https://id.twitch.tv/oauth2/authorize"
  @token_url "https://id.twitch.tv/oauth2/token"

  def gen_state do
    32
    |> :crypto.strong_rand_bytes()
    |> Base.encode64()
  end

  def get_app_access_token(client_id, client_secret) do
    body = %{
      client_id: client_id,
      client_secret: client_secret,
      grant_type: "client_credentials"
    }

    case Tesla.post(@token_url, URI.encode_query(body)) do
      {:ok, tesla_env} ->
        Jason.decode!(tesla_env.body)

      e ->
        Logger.error("Error getting app access token: #{inspect(e)}")
    end
  end

  # def authorize_url(
  #       state,
  #       client_id,
  #       redirect_uri \\ "http://localhost:3000",
  #       scopes \\ "channel:manage:polls+channel:read:polls"
  #     ) do
  #   scopes = URI.encode(scopes)

  #   params = %{
  #     response_type: "token",
  #     client_id: client_id,
  #     redirect_uri: redirect_uri,
  #     scope: scopes,
  #     state: state
  #   }

  #   @authorize_url <> "?" <> URI.encode_query(params, :rfc3986)
  # end

  # def get_access_token(auth_code) do
  #   body =
  #     %{
  #       client_id: System.get_env("DISCORD_CLIENT_ID"),
  #       client_secret: System.get_env("DISCORD_CLIENT_SECRET"),
  #       grant_type: "authorization_code",
  #       code: auth_code,
  #       redirect_uri: System.get_env("OAUTH_REDIRECT_URI")
  #     }
  #     |> URI.encode_query()

  #   headers = [{"Content-Type", "application/x-www-form-urlencoded"}]

  #   case HTTPoison.post(@token_url, body, headers) do
  #     {:ok, %HTTPoison.Response{body: token_body}} ->
  #       {:ok, Jason.decode!(token_body)}

  #     {:error, error} ->
  #       Logger.error("Error getting access token: #{inspect(error)}")
  #       {:error, error}
  #   end
  # end

  # def refresh_access_token(refresh_token) do
  #   body =
  #     %{
  #       client_id: System.get_env("DISCORD_CLIENT_ID"),
  #       client_secret: System.get_env("DISCORD_CLIENT_SECRET"),
  #       grant_type: "refresh_token",
  #       refresh_token: refresh_token
  #     }
  #     |> URI.encode_query()

  #   headers = [{"Content-Type", "application/x-www-form-urlencoded"}]

  #   case HTTPoison.post(@token_url, body, headers) do
  #     {:ok, %HTTPoison.Response{body: token_body}} ->
  #       {:ok, Jason.decode!(token_body)}

  #     {:error, error} ->
  #       Logger.error("Error getting access token: #{inspect(error)}")
  #       {:error, error}
  #   end
  # end

  # def revoke_token(token) do
  #   body =
  #     %{
  #       token: token
  #     }
  #     |> URI.encode_query()

  #   case HTTPoison.post(@revoke_url, body) do
  #     {:ok, %HTTPoison.Response{body: token_body}} ->
  #       {:ok, Jason.decode!(token_body)}

  #     {:error, error} ->
  #       Logger.error("Error getting access token: #{inspect(error)}")
  #       {:error, error}
  #   end
  # end
end
