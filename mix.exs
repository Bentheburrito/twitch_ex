defmodule TwitchEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :twitch_ex,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: []
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tesla, "~> 1.4.0"},
      {:mint, "~> 1.0"},
      {:castore, "~> 0.1"},
      {:plug_cowboy, "~> 2.0"},
      {:jason, "~> 1.3"}
    ]
  end
end
