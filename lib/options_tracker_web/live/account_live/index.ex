defmodule OptionsTrackerWeb.AccountLive.Index do
  use OptionsTrackerWeb, :live_view

  alias OptionsTracker.Accounts
  alias OptionsTracker.Accounts.Account
  alias OptionsTracker.Users
  alias OptionsTracker.Users.User
  import OptionsTrackerWeb.AccountLive.Helpers

  @impl true
  def mount(_params, %{"user_token" => user_token} = _session, socket) do
    current_user = Users.get_user_by_session_token(user_token)
    track(current_user)

    {:ok,
     socket
     |> assign(:accounts, list_accounts(current_user))
     |> assign(:current_user, current_user)}
  end

  @impl true
  def handle_params(params, url, socket) do
    {:noreply,
     socket
     |> assign(:url, URI.parse(url))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    account = Accounts.get_account!(id)

    unless socket.assigns.current_user.id == account.user_id do
      raise "Unauthorized edit of Account #{id} by user #{inspect(socket.assigns.current_user)}"
    end

    socket
    |> assign(:page_title, "Edit Account")
    |> assign(:account, account)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Account")
    |> assign(:account, %Account{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Accounts")
    |> assign(:account, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    account = Accounts.get_account!(id)

    if socket.assigns.current_user.id == account.user_id do
      {:ok, _} = Accounts.delete_account(account)
    end

    {:noreply, assign(socket, :accounts, list_accounts(socket.assigns.current_user))}
  end

  defp list_accounts(%User{id: user_id}) do
    Accounts.list_accounts(user_id)
  end
end
