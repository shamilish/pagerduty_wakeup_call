defmodule PagerdutyWakeupCall.Api do
  alias PagerdutyWakeupCall.Incidents
  use Plug.Router

  plug :match
  plug :dispatch

  get "/" do
    send_resp(conn, 200, "Hi")
  end

  get "/incidents" do
    {:ok, resp} = %{incidents: Incidents.get} |> Poison.encode
    send_resp(conn, 200, resp)
  end

  match _ do
    send_resp(conn, 404, "")
  end
end
