defmodule OptionsTrackerWeb.PositionLive.Index do
  use OptionsTrackerWeb, :live_view
  import OptionsTrackerWeb.PositionLive.Helpers

  alias OptionsTracker.Accounts
  alias OptionsTracker.Accounts.Account
  alias OptionsTracker.Accounts.Position
  alias OptionsTracker.Users
  alias OptionsTracker.Users.User

  @impl true
  def mount(_params, %{"user_token" => user_token} = _session, socket) do
    changeset = Accounts.change_position(%Position{account_id: 1})

    current_user = Users.get_user_by_session_token(user_token)
    current_account = current_user |> get_account()

    {:ok,
     socket
     |> assign(:current_user, current_user)
     |> assign(:current_account, current_account)
     |> assign(:positions, list_positions(current_account))
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Position")
    |> assign(:position, Accounts.get_position!(id))
  end

  defp apply_action(socket, :close, %{"id" => id}) do
    socket
    |> assign(:page_title, "Close Position")
    |> assign(:position, Accounts.get_position!(id))
  end

  @seconds_in_a_day 86_400
  defp apply_action(socket, :new, %{"account_id" => account_id}) do
    socket
    |> assign(:page_title, "New Position")
    |> assign(:account_id, account_id)
    |> assign(:position, %Position{
      account_id: 1,
      opened_at: DateTime.utc_now(),
      expires_at: DateTime.utc_now() |> DateTime.add(30 * @seconds_in_a_day, :second),
      short: true
    })
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Positions")
    |> assign(:position, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    position = Accounts.get_position!(id)
    {:ok, _} = Accounts.delete_position(position)

    {:noreply, assign(socket, :positions, list_positions(socket.assigns.current_account))}
  end

  def handle_event("validate", %{"position" => position_params}, socket) do
    changeset =
      socket.assigns.position
      |> Accounts.change_position(position_params |> compact())
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"position" => position_params}, socket) do
    save_position(socket, socket.assigns.live_action, position_params)
  end

  def handle_event("change_account", %{"account_id" => account_id}, socket) do
    {account_id, ""} = Integer.parse(account_id)

    {:noreply,
      socket
      |> assign(:current_account, socket.assigns.current_user.accounts |> Enum.find(&(&1.id == account_id)) || socket.assigns.current_account)}
  end

  defp save_position(socket, :edit, position_params) do
    case Accounts.update_position(socket.assigns.position, position_params) do
      {:ok, _position} ->
        {:noreply,
         socket
         |> put_flash(:info, "Position updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_position(socket, :new, position_params) do
    case Accounts.create_position(position_params) do
      {:ok, _position} ->
        {:noreply,
         socket
         |> put_flash(:info, "Position opened successfully")
         |> push_redirect(to: Routes.position_index_path(socket, :index))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp get_account(%User{accounts: []}) do
    nil
  end

  defp get_account(%User{accounts: [account | _]}) do
    account
  end

  defp list_positions(nil), do: []

  defp list_positions(%Account{id: account_id}) do
    Accounts.list_positions(account_id)
  end
end
