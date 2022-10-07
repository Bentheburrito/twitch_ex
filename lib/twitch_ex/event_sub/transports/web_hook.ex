defmodule TwitchEx.EventSub.Transports.WebHook do
  @moduledoc """
  Plug that responds with a 200 status code after verifying the given EventSub notification. Returns 402 if the
  notification could not be verified. Implements the `TwitchEx.EventSub.Transport` protocol.

  There are three configuration parameters required, in the form of an atom-keyed map:
  - `:callback_url` The URL that Twitch should post notifications, challenges, and other messages to. Note that Twitch
  requires the callback URL to use HTTPS.
  - `:secret` Your app's client secret.
  - `:notification_processor` This function will receive EventSub notifications, and their HTTP headers.

  For example:
  ```elixir
  %{
    callback_url: "https://myapp.com/twitch/eventsub",
    secret: "abcdefg...",
    notification_processor: fn event, details ->
      IO.inspect(details, label: "Event Headers")
      IO.inspect(event, label: "Event Payload")
    end
  }
  ```

  TODO: deduping multiple notifications, replay attacks
  """
  @behaviour TwitchEx.EventSub.Transport

  alias TwitchEx.EventSub
  alias TwitchEx.EventSub.Subscription
  alias TwitchEx.OAuth

  require Logger

  import Plug.Conn

  @subscriptions_endpoint "https://api.twitch.tv/helix/eventsub/subscriptions"
  @default_resp_body ""

  ### Transport callbacks ###

  def transport_spec() do
    Agent.get(__MODULE__, & &1)
  end

  def list_events(client_id, access_token) do
    headers = [{"authorization", "Bearer #{access_token}"}, {"client-id", client_id}]

    case Tesla.get(@subscriptions_endpoint, headers: headers) do
      {:ok, %{status: status} = env} when status in 200..299 ->
        {:ok, Jason.decode!(env.body)}

      {:ok, env} ->
        {:error, env.status}

      error ->
        error
    end
  end

  def subscribe(%Subscription{} = subscription) do
    headers = [
      {"authorization", "Bearer #{subscription.access_token}"},
      {"client-id", subscription.client_id},
      {"content-type", "application/json"}
    ]

    subscription_body = Subscription.to_message(subscription)

    case Tesla.post(@subscriptions_endpoint, subscription_body, headers: headers) do
      {:ok, %{status: status} = env} when status in 200..299 ->
        {:ok, Jason.decode!(env.body)}

      {:ok, %{status: 403}} ->
        auth_url = OAuth.simple_authorize_url(subscription.client_id, "SCOPES_HERE")

        Logger.warning("""
        \nTried to subscribe to type `#{subscription.type}`,
        but this client (#{subscription.client_id}) isn't authorized.

        You can fix this in two ways:

          1) Tell the user to visit the following link and authorize your client, replacing SCOPES_HERE
          with the required scopes for #{subscription.type}: #{auth_url}
          You can find which scopes are required in the Twitch Event List:
          https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types


          2) If you actually need a user code/token (you shouldn't unless using Twitch APIs besides EventSub),
          follow the Twitch OAuth docs with the help of the `TwitchEx.OAuth` functions:
          https://dev.twitch.tv/docs/authentication/getting-tokens-oauth/
        """)

        {:error, 403}

      {:ok, env} ->
        {:error, env.status}

      error ->
        error
    end
  end

  def unsubscribe(subscription_id, client_id, access_token) do
    headers = [{"authorization", "Bearer #{access_token}"}, {"client-id", client_id}]

    case Tesla.delete(@subscriptions_endpoint <> "?id=#{subscription_id}", headers: headers) do
      {:ok, %{status: status}} when status in 200..299 ->
        :ok

      {:ok, env} ->
        {:error, env.status}

      error ->
        error
    end
  end

  ### Plug callbacks ###

  def init(%{
        secret: secret,
        notification_processor: notification_processor,
        callback_url: callback_url
      }) do
    Agent.start_link(
      fn ->
        %{
          method: "webhook",
          callback: callback_url,
          secret: secret
        }
      end,
      name: __MODULE__
    )

    {secret, notification_processor}
  end

  def init(_) do
    raise(
      "Please provide a map of options with a `:secret`, a `:callback_url`, and a `:notification_processor`."
    )
  end

  def call(conn, {secret, notification_processor}) do
    with {:ok, body, conn} <- Plug.Conn.read_body(conn),
         headers_map <- Enum.into(conn.req_headers, %{}),
         {:ok, event_details} <- parse_headers(headers_map),
         {:ok, event} <- EventSub.verify_event(body, event_details, secret) do
      resp_body = handle_event(event, event_details, notification_processor)

      conn
      |> put_resp_content_type("text/plain")
      |> send_resp(200, resp_body)
    else
      {:error, error} ->
        Logger.error("Unable to parse event, returning 402: #{inspect(error)}")

        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(402, "")
    end
  end

  defp handle_event(event, %{message_type: "notification"} = event_details, notif_processor) do
    notif_processor.(event, event_details)

    @default_resp_body
  end

  @webhook_callback "webhook_callback_verification"
  defp handle_event(%{"challenge" => challenge}, %{message_type: @webhook_callback}, _) do
    challenge
  end

  defp handle_event(event, %{message_type: "revocation"}, _notif_processor) do
    case event["subscription"] do
      %{"status" => "user_removed"} ->
        nil

      %{"status" => "authorization_revoked"} ->
        nil

      %{"status" => "notification_failures_exceeded"} ->
        Logger.warning("Notification Failure Exceeded revocation from Twitch")
    end

    @default_resp_body
  end

  defp parse_headers(req_headers) do
    case req_headers do
      %{
        "twitch-eventsub-message-id" => message_id,
        "twitch-eventsub-message-retry" => message_retry,
        "twitch-eventsub-message-type" => message_type,
        "twitch-eventsub-message-signature" => message_signature,
        "twitch-eventsub-message-timestamp" => message_timestamp,
        "twitch-eventsub-subscription-type" => subscription_type,
        "twitch-eventsub-subscription-version" => subscription_version
      } ->
        event_details = %{
          message_id: message_id,
          message_retry: message_retry,
          message_type: message_type,
          message_signature: message_signature,
          message_timestamp: message_timestamp,
          subscription_type: subscription_type,
          subscription_version: subscription_version
        }

        {:ok, event_details}

      _ ->
        {:error, :missing_headers}
    end
  end
end
