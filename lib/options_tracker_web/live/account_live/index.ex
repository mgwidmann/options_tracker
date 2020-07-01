defmodule OptionsTrackerWeb.AccountLive.Index do
  use OptionsTrackerWeb, :live_view

  alias OptionsTracker.Accounts
  alias OptionsTracker.Accounts.Account
  alias OptionsTracker.Users

  @impl true
  def mount(_params, %{"user_token" => user_token} = _session, socket) do
    {:ok,
     socket
     |> assign(:accounts, list_accounts())
     |> assign(:current_user, Users.get_user_by_session_token(user_token))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Account")
    |> assign(:account, Accounts.get_account!(id))
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
    {:ok, _} = Accounts.delete_account(account)

    {:noreply, assign(socket, :accounts, list_accounts())}
  end

  defp list_accounts do
    Accounts.list_accounts()
  end
end
