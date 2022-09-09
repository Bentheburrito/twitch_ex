defmodule TwitchEx.EventSub.Subscription do
  @enforce_keys [:access_token, :client_id, :type, :condition, :transport, :version]
  defstruct @enforce_keys

  @type t() :: %__MODULE__{
          access_token: String.t(),
          client_id: String.t(),
          condition: map(),
          transport: module(),
          type: String.t(),
          version: String.t()
        }

  @spec new(
          access_token :: String.t(),
          client_id :: String.t(),
          condition :: map(),
          transport :: module(),
          type :: String.t(),
          version :: String.t()
        ) :: t()
  def new(access_token, client_id, condition, transport, type, version) do
    %__MODULE__{
      access_token: access_token,
      client_id: client_id,
      condition: condition,
      transport: transport,
      type: type,
      version: to_string(version)
    }
  end

  @spec new(Access.t(t())) :: t()
  def new(attrs) do
    new(
      attrs[:access_token],
      attrs[:client_id],
      attrs[:condition],
      attrs[:type],
      attrs[:transport],
      attrs[:version]
    )
  end

  def to_message(%__MODULE__{} = subscription) do
    subscription
    |> Map.from_struct()
    |> Map.update!(:transport, & &1.transport_spec)
    |> Jason.encode!()
  end
end
