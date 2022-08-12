defmodule TwitchEx.EventSub do
  @moduledoc """
  API for interacting with Twitch's EventSub service.
  """

  alias TwitchEx.EventSub
  alias TwitchEx.EventSub.Subscription

  def verify_event(json_event, event_details, secret) do
    message = event_details.message_id <> event_details.message_timestamp <> json_event

    hmac_signature =
      "sha256=" <> (:crypto.mac(:hmac, :sha256, secret, message) |> Base.encode16(case: :lower))

    if Plug.Crypto.secure_compare(hmac_signature, event_details.message_signature) do
      {:ok, Jason.decode!(json_event)}
    else
      {:error, :signatures_not_equal}
    end
  end

  def subscribe(transport_module, %Subscription{} = subscription) do
    transport_module.susbscribe(subscription)
  end
end
