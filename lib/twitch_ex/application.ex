defmodule TwitchEx.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Plug.Cowboy,
       scheme: :http,
       plug:
         {TwitchEx.EventSub.Transports.WebHook,
          %{
            callback_url: "https://bbbf-98-97-56-158.ngrok.io",
            secret: System.get_env("EVENTSUB_SECRET"),
            notification_processor: fn event, details ->
              IO.inspect(%{event: event, details: details}, label: "hey I got an event")
            end
          }},
       options: [port: 8080]}
    ]

    opts = [strategy: :one_for_one, name: TwitchEx.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
