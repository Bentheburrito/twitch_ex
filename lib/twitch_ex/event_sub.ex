defmodule TwitchEx.EventSub do
  @moduledoc """
  API for interacting with Twitch's EventSub service.

  Most functions take a `transport_module` argument, which must be a Module that implements the
  `TwitchEx.EventSub.Transport` behaviour. TwitchEx provides a Plug-based webhook transport out-of-the-box,
  `TwitchEx.EventSub.Transports.WebHook`. To use it, you should include it in your application supervision tree. For
  example:

  ```elixir
  defmodule MyApp.Application do
    use Application

    def start(_type, _args) do
      children = [
        {Plug.Cowboy,
        scheme: :http,
        plug:
          {TwitchEx.EventSub.Transports.WebHook,
            %{
              callback_url: "CALLBACK_URL_HERE",
              secret: CLIENT_SECRET_HERE,
              notification_processor: fn event, _details ->
                IO.inspect(event, label: "Event Received")
              end
            }},
        options: [port: 8080]}
      ]

      opts = [strategy: :one_for_one, name: MyApp.Supervisor]

      Supervisor.start_link(children, opts)
    end
  end
  ```

  Please see the `Webhook` documentation for more information on the configuration map.
  """

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

  @doc """
  List events the given client is subscribed to.

  TODO: Filtering, pagination
  """
  def list_events(transport_module, client_id, access_token) do
    transport_module.list_events(client_id, access_token)
  end

  def subscribe(transport_module, %Subscription{} = subscription) do
    transport_module.subscribe(subscription)
  end

  def unsubscribe(transport_module, subscription_id, client_id, access_token) do
    transport_module.unsubscribe(subscription_id, client_id, access_token)
  end
end
