defmodule PagerdutyWakeupCall.Mixfile do
  use Mix.Project

  def project do
    [app: :pagerduty_wakeup_call,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [
      extra_applications: [:logger],
      mod: {PagerdutyWakeupCall, []}
    ]
  end

  defp deps do
    [
      {:gmail, "~> 0.1.17"},
      {:cowboy, "~> 1.0.0"},
      {:plug, "~> 1.0"}
    ]
  end
end
