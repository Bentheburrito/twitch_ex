defmodule TwitchEx.EventSub.Subscription do
  @enforce_keys [:access_token, :secret, :client_id, :type, :condition, :transport, :version]
  defstruct @enforce_keys

  @type t() :: %__MODULE__{
          access_token: String.t(),
          client_id: String.t(),
          condition: map(),
          secret: String.t(),
          transport: module(),
          type: String.t(),
          version: integer()
        }

  @spec new(
          access_token :: String.t(),
          client_id :: String.t(),
          condition :: map(),
          secret :: String.t(),
          transport :: module(),
          type :: String.t(),
          version :: integer()
        ) :: t()
  def new(access_token, client_id, condition, secret, transport, type, version) do
    %__MODULE__{
      access_token: access_token,
      client_id: client_id,
      condition: condition,
      secret: secret,
      transport: transport,
      type: type,
      version: version
    }
  end

  @spec new(Access.t(t())) :: t()
  def new(attrs) do
    new(
      attrs[:access_token],
      attrs[:client_id],
      attrs[:condition],
      attrs[:secret],
      attrs[:type],
      attrs[:transport],
      attrs[:version]
    )
  end

  def to_message(%__MODULE__{} = subscription) do
    subscription
    |> Map.from_struct()
    |> Map.update!(:transport, & &1.transport_map)
    |> Jason.encode!()
  end
end
