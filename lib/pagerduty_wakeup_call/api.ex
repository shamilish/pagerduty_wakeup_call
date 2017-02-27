defmodule PagerdutyWakeupCall.Api do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/" do
    send_resp(conn, 200, "Hi")
  end

  match _ do
    send_resp(conn, 404, "")
  end
end
