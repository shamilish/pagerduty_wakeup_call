defmodule PagerdutyWakeupCall.Supervisor do
  alias PagerdutyWakeupCall.Incidents
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = [
      worker(Gmail.User, Incidents.gmail_params(), function: :start_mail),
      worker(Incidents, [])
    ]

    supervise(children, strategy: :one_for_all)
  end
end
