defmodule PagerdutyWakeupCall do
  use Application

  def start(_type, _args) do
    PagerdutyWakeupCall.Supervisor.start_link
  end
end
