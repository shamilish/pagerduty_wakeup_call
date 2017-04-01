defmodule PagerdutyWakeupCall.Incidents do
  use GenServer
  import Logger

  @incident_subject "[PagerDuty ALERT]"

  defstruct [:email, :incidents, :last_update]

  def start_link do
    GenServer.start_link(__MODULE__, [], [name: __MODULE__])
  end

  def init([]) do
    Logger.info "#{__MODULE__} init"
    email = Application.get_env(:pagerduty_wakeup_call, :email)
    state = %__MODULE__{email: email, incidents: []}

    {:ok, state}
  end

  def get do
    GenServer.call(__MODULE__, :get, 8000)
  end


  # Server

  def handle_call(:get, _from, state) do
    state = %{state | incidents: fetch_incidents(state.email)}
    {:reply, state.incidents, state}
  end

  def gmail_params do
    email = Application.get_env(:pagerduty_wakeup_call, :email)
    [email, refresh_token()]
  end

  defp fetch_incidents(email) do
    Logger.debug "#{__MODULE__} fetching incidents"

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
