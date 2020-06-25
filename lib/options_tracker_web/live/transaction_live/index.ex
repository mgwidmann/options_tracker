defmodule OptionsTrackerWeb.TransactionLive.Index do
  use OptionsTrackerWeb, :live_view
  import OptionsTrackerWeb.TransactionLive.Helpers

  alias OptionsTracker.Accounts
  alias OptionsTracker.Accounts.Transaction

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :transactions, list_transactions())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Position")
    |> assign(:transaction, Accounts.get_transaction!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Position")
    |> assign(:transaction, %Transaction{account_id: 2})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Positions")
    |> assign(:transaction, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    transaction = Accounts.get_transaction!(id)
    {:ok, _} = Accounts.delete_transaction(transaction)

    {:noreply, assign(socket, :transactions, list_transactions())}
  end

  defp list_transactions do
    Accounts.list_transactions()
  end
end
