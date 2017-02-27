# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :logger,
  level: :info

config :pagerduty_wakeup_call,
  email: System.get_env("EMAIL_ADDR"),
  refresh_interval: 5,
  api_port: 4000

config :gmail, :oauth2,
  client_id: System.get_env("CLIENT_ID"),
  client_secret: System.get_env("CLIENT_SECRET"),
  refresh_token: System.get_env("REFRESH_TOKEN")

config :gmail, :thread,
  pool_size: 10

config :gmail, :message,
  pool_size: 10
