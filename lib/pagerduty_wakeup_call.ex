defmodule PagerdutyWakeupCall do
  def get_emails do
    email = Application.get_env(:pagerduty_wakeup_call, :email)
    {:ok, _} = Gmail.User.start_mail(email, refresh_token())
    {:ok, emails} = Gmail.User.messages(email)

    ids = Enum.map(emails, fn e -> e.id end)
    Enum.map(ids, fn id ->
      case Gmail.User.message(email, id) do
        {:ok,  %{payload: %{headers: headers}}} -> Enum.find(headers, fn h -> h.name == "Subject" end) |> Map.get(:value)
        {:error, err_msg} -> IO.inspect err_msg
      end
    end)
  end

  defp refresh_token do
    case Application.get_env(:gmail, :oauth2) do
      config when(is_nil(config)) -> ""
      config -> Keyword.get(config, :refresh_token)
    end
  end
end
