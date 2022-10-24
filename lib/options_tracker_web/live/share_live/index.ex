defmodule OptionsTrackerWeb.ShareLive.Index do
  use OptionsTrackerWeb, :live_view

  alias OptionsTracker.Users
  import OptionsTrackerWeb.PositionLive.Helpers
  alias OptionsTracker.Accounts.Position.StatusType

  @impl true
  def mount(assigns, session, socket) do
    user_token = session["user_token"]

    current_user =
      if user_token do
        Users.get_user_by_session_token(user_token)
        |> track()
      end

    shares = Users.list_shares(current_user)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:shares, shares)
     |> assign(:current_user, current_user)}
  end


  def share_status([]), do: ""
  def share_status(statuses) when is_list(statuses) do
    statuses
    |> Enum.uniq()
    |> Enum.reduce(fn
      :open, _ -> :open
      _, :open -> :open
      :closed, s when s != :open -> :closed
      :rolled, s when s != :open -> :closed
      :exercised, s when s != :open -> :closed
    end)
    |> StatusType.name_for(true)
  end

  @impl true
  def handle_event("unshare", %{"hash" => hash}, socket) do
    share = Users.get_share(hash)
    if share.user.id == socket.assigns.current_user.id do
      Users.delete_share!(share)
    end

    {:noreply,
     socket
     |> push_redirect(to: Routes.share_index_path(socket, :index))}
  end
end
