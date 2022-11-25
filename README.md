# TwitchEx

A Twitch EventSub library for Elixir.

## Installation

```elixir
def deps do
  [
    {:twitch_ex, "~> 0.1.0"}
  ]
end
```

## Starting the EventSub WebHook

TwitchEx provides an EventSub webhook implementation out-of-the-box using :plug_cowboy. To use it, add the following to
your application supervision tree:

```elixir
{Plug.Cowboy,
  scheme: :http,
  plug:
    {TwitchEx.EventSub.Transports.WebHook,
    %{
      callback_url: "https://yourwebsite.com/eventsub/callback",
      secret: "your_event_sub_secret",
      notification_processor: fn event, details ->
        # process notification here
      end
    }},
  options: [port: 8080]}
```

Then, to subscribe to events:

```elixir
TwitchEx.EventSub.Subscription.new(
  access_token,
  client_id,
  condition,
  transport,
  type,
  version
)
|> TwitchEx.EventSub.Transports.WebHook.subscribe()
```

For more details on `TwitchEx.EventSub.Subscription.new/6`'s parameters, see the
[EventSub documentation](https://dev.twitch.tv/docs/eventsub/manage-subscriptions)

Also see the `TwitchEx.EventSub.Transports.WebHook` documentation for more information.

Out-of-the-box WebSocket support coming SoonTM
