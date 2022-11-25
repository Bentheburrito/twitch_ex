defmodule TwitchEx.EventSub.Transport do
  @moduledoc """
  A Behaviour that defines functions needed to facilitate EventSub interactions.

  TODO: Account for subscription cost; rate-limiting
  """
  alias TwitchEx.EventSub.Subscription

  @callback list_events(client_id :: String.t(), access_token :: String.t()) ::
              :ok | {:error, reason :: String.t()}
  @callback subscribe(Subscription.t()) :: {:ok, body :: map()} | {:error, reason :: String.t()}
  @callback unsubscribe(uuid :: String.t(), client_id :: String.t(), access_token :: String.t()) ::
              :ok | {:error, reason :: String.t()}
  @callback transport_spec() :: map()
end
