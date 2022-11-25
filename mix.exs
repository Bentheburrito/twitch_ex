defmodule TwitchEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :twitch_ex,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      description: description(),
      deps: deps(),
      package: package(),
      name: "TwitchEx",
      source_url: "https://github.com/Bentheburrito/twitch_ex",
      homepage_url: "https://github.com/Bentheburrito/twitch_ex"
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
      {:jason, "~> 1.3"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp description do
    "An Elixir wrapper for twitch.tv's EventSub API."
  end

  defp package do
    [
      name: "twitch_ex",
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/Bentheburrito/twitch_ex"}
    ]
  end
end
