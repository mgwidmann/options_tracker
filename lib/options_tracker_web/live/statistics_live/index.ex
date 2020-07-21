defmodule OptionsTrackerWeb.StatisticsLive.Index do
  use OptionsTrackerWeb, :live_view
  alias OptionsTracker.Accounts
  alias OptionsTracker.Users

  @impl true
  def mount(params, %{"user_token" => user_token} = _session, socket) do
    account_id = params["account_id"] || "all"
    account_id = if(account_id == "all", do: :all, else: Integer.parse(account_id) |> elem(0))

    current_user = Users.get_user_by_session_token(user_token)

    current_account =
      if(account_id == :all,
        do: current_user.accounts,
        else:
          current_user.accounts
          |> Enum.find(fn account ->
            account.id == account_id
          end)
      )

    {:ok,
     socket
     |> assign(:current_user, current_user)
     |> assign(:current_account, current_account)
     |> assign(:current_account_id, account_id)
     |> assign(:profit_loss, Accounts.profit_loss(current_account))}
  end
end
