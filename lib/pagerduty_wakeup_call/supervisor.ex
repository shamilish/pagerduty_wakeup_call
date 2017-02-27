defmodule PagerdutyWakeupCall.Supervisor do
  alias PagerdutyWakeupCall.{Incidents, Api}
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    api_port = Application.get_env(:pagerduty_wakeup_call, :api_port)

    children = [
      worker(Gmail.User, Incidents.gmail_params(), function: :start_mail),
      worker(Incidents, []),
      Plug.Adapters.Cowboy.child_spec(:http, Api, [], [port: api_port])
    ]

    supervise(children, strategy: :one_for_all)
  end
end
