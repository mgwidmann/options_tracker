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
    changeset = Accounts.change_position(%Position{})
    account_id = params["account_id"] || "all"
    account_id = if(account_id == "all", do: :all, else: Integer.parse(account_id) |> elem(0))

    current_user = Users.get_user_by_session_token(user_token)

    current_account =
      if(account_id == :all,
        do: current_user.accounts,
        else: get_account(current_user, account_id)
      )

    search_changeset = Search.new(current_account)

    {:ok,
     socket
     |> assign(:current_user, current_user)
     |> assign(:current_account, current_account)
     |> assign(:current_account_id, account_id)
     |> assign(:positions, list_positions(search_changeset))
     |> assign(:changeset, changeset)
     |> assign(:profit_loss, Accounts.profit_loss(current_account))
     |> assign(:search_changeset, search_changeset)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
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
      opened_at: DateTime.utc_now() |> DateTime.to_date(),
      expires_at:
        DateTime.utc_now() |> DateTime.add(30 * @seconds_in_a_day, :second) |> DateTime.to_date(),
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
    changeset =
      (socket.assigns.position || %Position{})
      |> Accounts.change_position(position_params |> compact())
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

  def handle_event("save", %{"position" => position_params}, socket) do
    save_position(socket, socket.assigns.live_action, position_params)
  end

  def handle_event("change_account", %{"account_id" => "all"}, socket) do
    {:noreply,
     socket
     |> push_redirect(to: Routes.position_index_path(socket, :index))}
  end

  def handle_event("change_account", %{"account_id" => account_id}, socket) do
    {account_id, ""} = Integer.parse(account_id)

    {:noreply,
     socket
     |> push_redirect(to: Routes.position_account_index_path(socket, :index, account_id))}
  end

  def handle_event("cancel", _, socket) do
    search_changest = Search.new(socket.assigns.current_account)

    {:noreply,
     socket
     |> assign(:search_changeset, search_changest)
     |> assign(:live_action, nil)
     |> assign(:changeset, Accounts.change_position(%Position{}))
     |> assign(:positions, list_positions(search_changest))}
  end

  defp save_position(socket, :edit, position_params) do
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
         |> assign(:positions, list_positions(search_changest))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_position(socket, :new, position_params) do
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
         |> assign(:positions, list_positions(search_changest))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

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
end
