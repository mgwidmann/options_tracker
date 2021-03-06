defmodule OptionsTrackerWeb.StatisticsLive.Index do
  use OptionsTrackerWeb, :live_view
  alias OptionsTracker.Accounts
  alias OptionsTracker.Users
  import OptionsTrackerWeb.PositionLive.Helpers

  @impl true
  def mount(params, %{"user_token" => user_token} = _session, socket) do
    current_user = Users.get_user_by_session_token(user_token)
    track(current_user)

    {account_id, current_account, current_account_changeset} = get_params(params, current_user)

    {:ok,
     socket
     |> assign(:current_user, current_user)
     |> assign(:current_account, current_account)
     |> assign(:current_account_changeset, current_account_changeset)
     |> assign(:current_account_id, account_id)}
  end

  # Handle public route
  def mount(params, _empty_session, socket) do
    {account_id, current_account, nil} = get_params(params, nil)

    if current_account do
      {:ok,
        socket
        |> assign(:current_user, nil)
        |> assign(:current_account, current_account)
        |> assign(:current_account_id, account_id)}
    else
      {:ok,
        socket
        |> push_redirect(to: "/404.html")}
    end
  end

  def get_params(params, current_user) do
    account_id = params["account_id"] || "all"
    account_id = if(account_id == "all", do: :all, else: Integer.parse(account_id) |> elem(0))

    current_account =
      cond do
        account_id == :all ->
          current_user && current_user.accounts
        current_user && current_user.accounts ->
          current_user.accounts
          |> Enum.find(fn account ->
            account.id == account_id
          end)
        !current_user ->
          Accounts.get_public_account(account_id)
      end

    current_account_changeset = if account_id != :all && current_user do
      Accounts.change_account(current_account)
    end

    {account_id, current_account, current_account_changeset}
  end

  @impl true
  def handle_params(params, url, socket) do
    tab = tab_to_atom(params["tab"] || "daily")

    profit_loss = Accounts.profit_loss(socket.assigns.current_account, tab)
    metrics = Accounts.calculate_metrics(Map.values(profit_loss) |> List.flatten())

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
     |> assign(:metrics, metrics)
     |> assign(:current_tab, tab)
     |> assign(:url, URI.parse(url))}
  end

  @impl true
  def handle_event("save", %{"account" => account_params}, socket) do
    case Accounts.update_account(socket.assigns.current_account, account_params) do
      {:ok, account} ->
        changeset = Accounts.change_account(account)
        {:noreply,
          socket
          |> assign(:current_account, account)
          |> assign(:current_account_changeset, changeset)}
      {:error, changeset} ->
        {:noreply,
          socket
          |> assign(:current_account_changeset, changeset)}
    end
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
    |> Enum.reduce(Decimal.new(0), &Decimal.add(&1 || Decimal.new(0), &2 || Decimal.new(0)))
  end

  def max_loss(nil), do: nil

  def max_loss(positions) do
    positions
    |> Enum.map(&Accounts.calculate_max_loss(&1))
    |> Enum.reject(&Decimal.inf?(&1))
    |> Enum.reduce(Decimal.from_float(0.0), &Decimal.add(&1, &2))
  end

  def wins([]), do: 0.0
  def wins(nil), do: 0.0

  def wins(profit_loss_list) do
    total = Enum.count(profit_loss_list)
    profitable = Enum.count(profit_loss_list, &(Decimal.cmp(&1, Decimal.from_float(0.0)) in [:eq, :gt]))

    if total == 0 do
      0.0
    else
      profitable / total
    end
  end

  def profit_loss_class(nil), do: nil

  def profit_loss_class(profit_loss) do
    if Decimal.cmp(profit_loss, Decimal.new(0)) in [:gt, :eq] do
      "has-text-success"
    else
      "has-text-danger"
    end
  end

  def profit_loss_json(profit_loss_data, range) do
    data_points = profit_loss_json_data(profit_loss_data, range)

    Jason.encode!(data_points)
  end

  def profit_loss_json_data(profit_loss_data, range) do
    for date <- range do
      if profit_loss_data[date] do
        pl = profit_loss_data[date] |> Enum.map(& &1.profit_loss) |> profit_loss()

        if pl do
          # Make the date always 4pm EST so it does not show the day before
          %{x: "#{date}T20:00:00.000Z", y: Decimal.to_float(pl)}
        end
      end
    end
    |> Enum.filter(& &1)
  end

  def wins_json(profit_loss_data, range) do
    data_points = wins_json_data(profit_loss_data, range, false)

    Jason.encode!(data_points)
  end

  def weighted_wins_json(profit_loss_data, range) do
    data_points = wins_json_data(profit_loss_data, range, false)

    Jason.encode!(data_points)
  end

  def wins_json_data(profit_loss_data, range, weighted) do
    for date <- range do
      if profit_loss_data[date] do
        profit_loss_list = profit_loss_data[date] |> Enum.map(& &1.profit_loss)

        y_data = if weighted do
          Accounts.weighted_win_percentage(profit_loss_list)
        else
          wins(profit_loss_list)
        end
        # Make the date always 4pm EST so it does not show the day before
        %{x: "#{date}T20:00:00.000Z", y: y_data |> Decimal.from_float() |> Decimal.mult(100) |> Decimal.round(2)}
      end
    end
    |> Enum.filter(& &1)
  end
end
