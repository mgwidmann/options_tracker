defmodule OptionsTrackerWeb.AccountLive.AccountsDropdown do
  use OptionsTrackerWeb, :live_component

  alias OptionsTracker.Accounts
  import OptionsTrackerWeb.AccountLive.Helpers

  @impl true

  @spec update(%{account_path_fun: (any, any, any, any -> any), all_path_fun: (any, any, any -> any)}, Phoenix.LiveView.Socket.t()) :: {:ok, Phoenix.LiveView.Socket.t()}
  def update(%{all_path_fun: all_path_fun, account_path_fun: account_path_fun} = assigns, socket) when is_function(all_path_fun, 3) and is_function(account_path_fun, 4) do
    current_account =
      Map.get_lazy(socket.assigns, :current_account, fn ->
        case assigns[:account_id] do
          nil -> (assigns[:current_user] || socket.assigns.current_user).accounts
          account_id -> Accounts.get_account!(account_id)
        end
      end)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:current_account, current_account)}
  end

  @impl true
  def handle_event("change_account", %{"account_id" => "all"}, socket) do
    {:noreply,
     socket
     |> push_redirect(to: socket.assigns.all_path_fun.(socket, :index, socket.assigns[:path_params] || []))}
  end

  def handle_event("change_account", %{"account_id" => account_id}, socket) do
    {account_id, ""} = Integer.parse(account_id)

    {:noreply,
     socket
     |> push_redirect(to: socket.assigns.account_path_fun.(socket, :index, account_id, socket.assigns[:path_params] || []))}
  end
end
