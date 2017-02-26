defmodule PagerdutyWakeupCall.Incidents do
  use GenServer
  import Logger

  @incident_subject "[PagerDuty ALERT]"

  defstruct [:email, :refresh_interval, :incidents, :last_update]

  def start_link do
    GenServer.start_link(__MODULE__, [], [name: __MODULE__])
  end

  def init([]) do
    Logger.info "#{__MODULE__} init"
    email = Application.get_env(:pagerduty_wakeup_call, :email)
    refresh_interval = Application.get_env(:pagerduty_wakeup_call, :refresh_interval)
    incidents = fetch_incidents(email)
    state = %__MODULE__{email: email, refresh_interval: refresh_interval, incidents: incidents, last_update: Time.utc_now}

    periodic_refresher(refresh_interval)
    {:ok, state}
  end

  def get do
    GenServer.call(__MODULE__, :get)
  end

  def refresh do
    GenServer.cast(__MODULE__, :refresh)
  end

  # Server

  def handle_call(:get, _from, state) do
    {:reply, state.incidents, state}
  end

  def handle_cast(:refresh, state) do
    state = %{state | incidents: fetch_incidents(state.email), last_update: Time.utc_now}
    {:noreply, state}
  end

  def gmail_params do
    email = Application.get_env(:pagerduty_wakeup_call, :email)
    [email, refresh_token()]
  end

  def periodic_refresher(interval) do
    Task.async(fn ->
      :timer.sleep(interval * 1000)
      refresh()
      periodic_refresher(interval)
    end)
  end

  defp fetch_incidents(email) do
    Logger.info "#{__MODULE__} fetching incidents"

    {:ok, emails} = Gmail.User.messages(email)
    ids = Enum.map(emails, &Map.get(&1, :id))

    incidents = ids |> extract_subjects(email) |> filter_incidents

    Logger.info("#{__MODULE__} Incident count #{length incidents}")
    incidents
  end

  defp extract_subjects(email_ids, email) do
    email_ids |>
    Enum.map(fn id ->
      case Gmail.User.message(email, id) do
        {:ok,  %{payload: %{headers: headers}}} -> Enum.find(headers, fn h -> h.name == "Subject" end) |> Map.get(:value)
        {:error, err_msg} -> raise "#{__MODULE__} Error fetching incidents - #{inspect err_msg}"
      end
    end)
  end

  def filter_incidents(email_subjects) do
    email_subjects |>
    Enum.filter(&String.contains?(&1, @incident_subject))
  end

  defp refresh_token do
    case Application.get_env(:gmail, :oauth2) do
      config when(is_nil(config)) -> ""
      config -> Keyword.get(config, :refresh_token)
    end
  end
end
