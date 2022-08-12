defmodule TwitchEx.EventSub.Transport do
  alias TwitchEx.EventSub.Subscription

  @callback subscribe(Subscription.t()) :: :ok | {:error, reason :: String.t()}
  @callback transport_map() :: map()
end
