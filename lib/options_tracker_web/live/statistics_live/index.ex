defmodule OptionsTrackerWeb.StatisticsLive.Index do
  use OptionsTrackerWeb, :live_view
  alias OptionsTracker.Accounts
  alias OptionsTracker.Users

  @impl true
  def mount(params, %{"user_token" => user_token} = _session, socket) do
    account_id = params["account_id"] || "all"
    account_id = if(account_id == "all", do: :all, else: Integer.parse(account_id) |> elem(0))

    current_user = Users.get_user_by_session_token(user_token)
    track(current_user)

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
     |> assign(:current_account_id, account_id)}
  end

  @impl true
  def handle_params(params, url, socket) do
    tab = tab_to_atom(params["tab"] || "daily")

    profit_loss = Accounts.profit_loss(socket.assigns.current_account, tab)

    range =
      profit_loss_range(profit_loss)
      |> Enum.filter(fn date ->
        case tab do
          :daily ->
            true

          :weekly ->
            Timex.compare(date, Timex.beginning_of_week(date, :sun)) == 0

          :monthly ->
            Timex.compare(date, Timex.beginning_of_month(date)) == 0

          :yearly ->
            Timex.compare(date, Timex.beginning_of_year(date)) == 0
        end
      end)

    {:noreply,
     socket
     |> assign(:profit_loss, profit_loss)
     |> assign(:profit_loss_range, range)
     |> assign(:current_tab, tab)
     |> assign(:url, URI.parse(url))}
  end

  defp tab_to_atom("daily"), do: :daily
  defp tab_to_atom("weekly"), do: :weekly
  defp tab_to_atom("monthly"), do: :monthly
  defp tab_to_atom("yearly"), do: :yearly

  defp profit_loss_range(profit_loss) do
    today = Timex.today()
    dates = Map.keys(profit_loss)
    min = Enum.min_by(dates, &Timex.diff(&1, today, :day), fn -> Timex.today() end)
    max = Enum.max_by(dates, &Timex.diff(&1, today, :day), fn -> Timex.today() end)

    Date.range(min, max)
  end

  def largest_win(nil), do: nil

  def largest_win(profit_loss_list) when is_list(profit_loss_list) do
    win =
      profit_loss_list
      |> Enum.filter(&(Decimal.cmp(&1, Decimal.new(0)) in [:gt, :eq]))
      |> Enum.max_by(&Decimal.to_float(&1), fn -> nil end)

    if win do
      currency_string(win)
    end
  end

  def largest_loss(nil), do: nil

  def largest_loss(profit_loss_list) when is_list(profit_loss_list) do
    loss =
      profit_loss_list
      |> Enum.filter(&(Decimal.cmp(&1, Decimal.new(0)) in [:lt]))
      |> Enum.min_by(&Decimal.to_float(&1), fn -> nil end)

    if loss do
      currency_string(loss)
    end
  end

  def profit_loss(nil), do: nil

  def profit_loss(profit_loss_list) do
    profit_loss_list
    |> Enum.reduce(Decimal.new(0), &Decimal.add(&1, &2))
  end

  def profit_loss_class(nil), do: nil

  def profit_loss_class(profit_loss) do
    if Decimal.cmp(profit_loss, Decimal.new(0)) in [:gt, :eq] do
      "has-text-success"
    else
      "has-text-danger"
    end
  end
end
