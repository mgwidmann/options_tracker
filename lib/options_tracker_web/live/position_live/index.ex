defmodule OptionsTrackerWeb.PositionLive.Index do
  use OptionsTrackerWeb, :live_view
  import OptionsTrackerWeb.PositionLive.Helpers

  alias OptionsTracker.Accounts
  alias OptionsTracker.Accounts.Position
  alias OptionsTracker.Users
  alias OptionsTracker.Users.User
  alias OptionsTracker.Search

  @impl true
  def mount(params, %{"user_token" => user_token} = _session, socket) do
    account_id = params["account_id"] || "all"
    account_id = if(account_id == "all", do: :all, else: Integer.parse(account_id) |> elem(0))

    current_user = Users.get_user_by_session_token(user_token)
    track(current_user)

    current_account =
      if(account_id == :all,
        do: current_user.accounts,
        else: get_account(current_user, account_id)
      )

    changeset = Accounts.change_position(%Position{})

    search_changeset = Search.new(current_account)

    {:ok,
     socket
     |> assign(:current_user, current_user)
     |> assign(:current_account, current_account)
     |> assign(:current_account_id, account_id)
     |> assign(:positions, list_positions(search_changeset))
     |> assign(:changeset, changeset)
     |> assign(:share_mode, false)
     |> assign(:shares, %{})
     |> assign(:profit_loss, Accounts.profit_loss(current_account))
     |> assign(:search_changeset, search_changeset)}
  end

  @impl true
  def handle_params(params, url, socket) do
    {:noreply,
     socket
     |> assign(:url, URI.parse(url))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    position = Accounts.get_position!(id)
    changeset = Accounts.change_position(position)

    socket
    |> assign(:page_title, "Edit Position")
    |> assign(:position, position)
    |> assign(:changeset, changeset)
  end

  defp apply_action(socket, :close, %{"id" => id}) do
    socket
    |> assign(:page_title, "Close Position")
    |> assign(:position, Accounts.get_position!(id))
  end

  @seconds_in_a_day 86_400
  defp apply_action(socket, :new, _params) do
    position = %Position{}

    position_params = %{
      account_id: socket.assigns.current_account.id,
      fees: socket.assigns.current_account.opt_open_fee,
      opened_at: DateTime.utc_now() |> DateTime.to_date(),
      count: 1,
      expires_at: DateTime.utc_now() |> DateTime.add(30 * @seconds_in_a_day, :second) |> DateTime.to_date(),
      short: true,
      type: :put
    }

    changeset = Accounts.change_position(position, position_params)

    socket
    |> assign(:page_title, "New Position")
    |> assign(:position, position)
    |> assign(:changeset, changeset)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Positions")
    |> assign(:position, nil)
    # Clear out
    |> assign(:changeset, nil)
  end

  defp apply_action(socket, :delete, %{"id" => id}) do
    position = Accounts.get_position!(id)

    socket
    |> assign(:page_title, "Delete Position")
    |> assign(:position, position)
    # Clear out
    |> assign(:changeset, nil)
  end

  defp apply_action(socket, :notes, %{"id" => id}) do
    position = Accounts.get_position!(id)
    changeset = Accounts.change_position(position)

    socket
    |> assign(:page_title, "Edit Notes")
    |> assign(:position, position)
    |> assign(:changeset, changeset)
  end

  defp apply_action(socket, :reopen, %{"id" => id}) do
    position = Accounts.get_position!(id)

    case Accounts.update_position(
           position,
           %{
             status: Accounts.position_status_open(),
             closed_at: nil,
             exit_price: nil,
             profit_loss: nil
           },
           socket.assigns.current_user
         ) do
      {:ok, _position} ->
        search_changest = Search.new(socket.assigns.current_account)

        socket
        |> assign(:search_changeset, search_changest)
        |> assign(:live_action, nil)
        |> assign(:changeset, Accounts.change_position(%Position{}))
        |> assign(:positions, list_positions(search_changest))

      {:error, %Ecto.Changeset{} = changeset} ->
        assign(socket, :changeset, changeset)
    end
  end

  @impl true
  def handle_event(
        "delete",
        %{"delete_params" => %{"id" => id, "return_to" => return_to}},
        socket
      ) do
    position = Accounts.get_position!(id)
    {:ok, _} = Accounts.delete_position(position)

    {:noreply,
     socket
     |> assign(:positions, list_positions(socket.assigns.search_changeset))
     |> put_flash(:danger, "Position deleted successfully!")
     |> push_redirect(to: return_to)}
  end

  def handle_event("validate", %{"position" => position_params}, socket) do
    account =
      if(match?([_ | _], socket.assigns.current_account),
        do: socket.assigns.position,
        else: socket.assigns.current_account
      )

    changeset =
      (socket.assigns.position || %Position{})
      |> Accounts.change_position(position_params |> compact())
      |> position_params_fees(socket.assigns.changeset, socket.assigns.position, account)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("validate", _attrs, socket) do
    handle_event("validate", %{"position" => %{}}, socket)
  end

  def handle_event("search", %{"search_form" => params}, socket) do
    search_changeset = Search.new(socket.assigns.current_account, params)

    {:noreply,
     socket
     |> assign(:search_changeset, search_changeset)
     |> assign(:positions, list_positions(search_changeset))}
  end

  def handle_event("save", %{"position" => position_params} = params, socket) do
    save_position(socket, socket.assigns.live_action, position_params, Map.get(params, "return_to", Routes.position_index_path(socket, :index)))
  end

  def handle_event("cancel", _, socket) do
    {:noreply,
     socket
     |> push_redirect(to: return_to_path(socket, socket.assigns.current_account_id))}
  end

  def handle_event("share", _, socket) do
    {:noreply,
     socket
     |> assign(:shares, %{})
     |> assign(:share_mode, !socket.assigns.share_mode)}
  end

  def handle_event("add_share", %{"id" => position_id}, socket) do
    position_id = String.to_integer(position_id)

    {:noreply,
     socket
     |> assign(:shares, Map.put(socket.assigns.shares, position_id, true))}
  end

  def handle_event("add_all", _, socket) do
    all_positions = for p <- socket.assigns.positions, into: %{}, do: {p.id, true}

    {:noreply,
     socket
     |> assign(:shares, Map.merge(socket.assigns.shares, all_positions))}
  end

  def handle_event("remove_share", %{"id" => position_id}, socket) do
    position_id = String.to_integer(position_id)

    {:noreply,
     socket
     |> assign(:shares, Map.drop(socket.assigns.shares, [position_id]))}
  end

  def handle_event("save_share", _, socket) do
    position_ids = Map.keys(socket.assigns.shares)

    {:ok, share} = Users.create_share(socket.assigns.current_user, position_ids)

    {:noreply,
     socket
     |> assign(:share_mode, false)
     |> assign(:shares, %{})
     |> push_redirect(to: Routes.share_show_path(socket, :show, id: share.hash))}
  end

  defp save_position(socket, :edit, position_params, return_to) do
    case Accounts.update_position(
           socket.assigns.position,
           position_params,
           socket.assigns.current_user
         ) do
      {:ok, _position} ->
        search_changest = Search.new(socket.assigns.current_account)

        {:noreply,
         socket
         |> assign(:search_changeset, search_changest)
         |> assign(:live_action, nil)
         |> assign(:changeset, Accounts.change_position(%Position{}))
         |> assign(:positions, list_positions(search_changest))
         |> push_redirect(to: return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_position(socket, :new, position_params, return_to) do
    case Accounts.create_position(
           position_params
           |> Map.merge(%{status: Accounts.position_status_open()}),
           socket.assigns.current_user
         ) do
      {:ok, _position} ->
        search_changest = Search.new(socket.assigns.current_account)

        {:noreply,
         socket
         |> assign(:search_changeset, search_changest)
         |> assign(:live_action, nil)
         |> assign(:changeset, Accounts.change_position(%Position{}))
         |> assign(:positions, list_positions(search_changest))
         |> push_redirect(to: return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @spec get_account(User.t() | nil, non_neg_integer) :: nil | Account.t()
  defp get_account(%User{accounts: []}, _account_id) do
    nil
  end

  defp get_account(%User{accounts: accounts}, account_id) do
    accounts
    |> Enum.find(fn account ->
      account.id == account_id
    end)
  end

  defp list_positions(search_changeset) do
    Search.search(search_changeset)
  end

  defp position_params_fees(
         %Ecto.Changeset{changes: %{count: count}} = changeset,
         %Ecto.Changeset{changes: %{count: count}},
         _position,
         _account
       ) do
    # Don't change anything when count does not change
    changeset
  end

  defp position_params_fees(
         %Ecto.Changeset{changes: %{count: count}} = changeset,
         %Ecto.Changeset{changes: %{count: _other_count}},
         position,
         account
       ) do
    fee_per =
      if(Position.TransType.stock?(position.type),
        do: account.stock_open_fee,
        else: account.opt_open_fee
      )

    changeset
    |> Ecto.Changeset.put_change(:fees, Decimal.mult(fee_per, count))
  end

  defp position_params_fees(changeset, _prior_changeset, _position, _account) do
    changeset
  end
end
