defmodule TwitchEx.OAuth do
  @moduledoc """
  Custom Twitch OAuth2/Client Credentials Grant Flow solution.

  ### Twitch Documentation:
  https://dev.twitch.tv/docs/authentication/getting-tokens-oauth/
  """

  require Logger

  @authorize_url "https://id.twitch.tv/oauth2/authorize"
  @token_url "https://id.twitch.tv/oauth2/token"

  def gen_state do
    32
    |> :crypto.strong_rand_bytes()
    |> Base.encode64()
  end

  @doc """
  Gets an application access token for the given client's ID and secret via the Client Credentials Flow. Returns the
  decoded post body.

  #### Example return value:
  ```elixir
  %{
    "access_token" => "some token here",
    "expires_in" => 5011271,
    "token_type" => "bearer"
  }
  ```

  #### Twitch Client Credentials Flow documentation
  https://dev.twitch.tv/docs/authentication/getting-tokens-oauth/#client-credentials-grant-flow
  """
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

  def simple_authorize_url(client_id, scopes) do
    scopes = URI.encode(scopes)

    params = %{
      response_type: "code",
      client_id: client_id,
      redirect_uri: "https://twitch.tv",
      scope: scopes
    }

    @authorize_url <> "?" <> URI.encode_query(params)
  end

  ### AUTHORIZATION CODE GRANT FLOW ###
  def authorize_url(state, client_id, redirect_uri, scopes) do
    scopes = URI.encode(scopes)

    params = %{
      response_type: "code",
      client_id: client_id,
      redirect_uri: redirect_uri,
      scope: scopes,
      state: state
    }

    @authorize_url <> "?" <> URI.encode_query(params)
  end

  # def start_auth_code_grant_flow(client_id, redirect_uri, scopes \\ "channel:read:redemptions") do
  #   state = gen_state()
  #   auth_url = authorize_url(state, client_id, redirect_uri, scopes)
  #   task = Task.start(&listen_for_auth_code(state))
  #   auth_url
  # end

  # defp listen_for_auth_code(state) do
  # end
  ### END AUTHORIZATION CODE GRANT FLOW ###

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
