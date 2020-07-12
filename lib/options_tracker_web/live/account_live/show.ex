defmodule OptionsTrackerWeb.AccountLive.Show do
  use OptionsTrackerWeb, :live_view

  alias OptionsTracker.Accounts
  alias OptionsTracker.Users

  @impl true
  def mount(_params, %{"user_token" => user_token} = _session, socket) do
    {:ok,
     socket
     |> assign(:current_user, Users.get_user_by_session_token(user_token))}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    account = Accounts.get_account!(id)
    unless socket.assigns.current_user.id == account.user_id do
      raise "Unauthorized show of account id #{id} by user #{inspect socket.assigns.current_user}"
    end

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:account, account)}
  end

  defp page_title(:show), do: "Show Account"
  defp page_title(:edit), do: "Edit Account"
end
