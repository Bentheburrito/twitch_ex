defmodule TwitchExTest do
  use ExUnit.Case
  doctest TwitchEx

  test "greets the world" do
    assert TwitchEx.hello() == :world
  end
end
