defmodule TwitchEx.EventSub.Transports.WebHook.VerifyEventPlug do
  @moduledoc """
  Plug that responds with a 200 status code after verifying the given EventSub notification. Returns 402 if the
  notification could not be verified.

  TODO:
  - Replay Attacks
  """
  alias TwitchEx.EventSub

  require Logger

  import Plug.Conn

  def init(%{secret: secret, notification_processor: notification_processor}) do
    {secret, notification_processor}
  end

  def init(_) do
    raise("Please provide a map of options with a `:secret` and an `:notification_processor`.")
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

    ""
  end

  defp handle_event(
         %{"challenge" => challenge},
         %{message_type: "webhook_callback_verification"},
         _notif_processor
       ) do
    challenge
  end

  defp handle_event(event, %{message_type: "revocation"}, _notif_processor) do
    case event["subscription"] do
      %{"status" => "user_removed"} ->
        nil

      %{"status" => "authorization_revoked"} ->
        nil

      %{"status" => "notification_failures_exceeded"} ->
        Logger.warning("Notification Failure Exceeded revokation from Twitch")
    end

    ""
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
