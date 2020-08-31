defmodule OptionsTrackerWeb.ShareLive.Show do
  use OptionsTrackerWeb, :live_view

  alias OptionsTracker.Users

  @impl true
  def mount(assigns, session, socket) do
    user_token = session["user_token"]

    current_user =
      if user_token do
        Users.get_user_by_session_token(user_token)
        |> track()
      end

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:current_user, current_user)}
  end

  @impl true
  def handle_params(%{"id" => hash_id}, url, socket) do
    share = Users.get_share(hash_id)

    if share do
      {:noreply,
       socket
       |> assign(:share, share)
       |> assign(:url, url)
       |> assign(:user, share.user)
       |> assign(:positions, share.positions)}
    else
      {:noreply,
       socket
       |> assign(:share, nil)}
    end
  end

  @impl true
  def handle_event("unshare", _, socket) do
    if socket.assigns.share.user.id == socket.assigns.current_user.id do
      Users.delete_share!(socket.assigns.share)
    end

    {:noreply,
     socket
     |> push_redirect(to: Routes.position_index_path(socket, :index))}
  end
end
