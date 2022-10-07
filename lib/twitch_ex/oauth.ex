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

  @doc """
  Generates an authorization URL that simply redirects to twitch.tv. You should only use this function when you don't
  need the auth code to complete the [Authorization Code Grant Flow](https://dev.twitch.tv/docs/authentication/getting-tokens-oauth/#authorization-code-grant-flow).
  Otherwise, you should use `authorization_url/4`.
  """
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

  @doc """
  Generates an authorization URL that the user visits to grant your app certain scopes. You must implement the callback
  at `redirect_uri` that collects the returned code and retrieves the actual oauth token.
  """
  def authorization_url(state, client_id, redirect_uri, scopes) do
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
end
