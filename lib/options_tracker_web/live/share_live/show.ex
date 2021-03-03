defmodule OptionsTrackerWeb.ShareLive.Show do
  use OptionsTrackerWeb, :live_view

  alias OptionsTracker.Users
  alias OptionsTracker.Users.Share
  alias OptionsTracker.Accounts

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
       |> assign(:share_preview, false)
       |> assign(:url, url)
       |> assign(:user, share.user)
       |> assign(:positions, share.positions)
       |> assign(:metrics, Accounts.calculate_metrics(share.positions))}
    else
      {:noreply,
       socket
       |> assign(:share, nil)
       |> assign(:positions, nil)}
    end
  end

  def handle_params(%{"position_ids" => position_ids}, url, socket) do
    if socket.assigns.current_user do
      account_ids = socket.assigns.current_user.accounts |> Enum.map(& &1.id)
      position_ids = String.split(position_ids, ",") # Joined by comma to reduce link size
      positions = Accounts.get_positions(position_ids, account_ids)

      {:noreply,
        socket
        |> assign(:share, %Share{})
        |> assign(:share_preview, true)
        |> assign(:positions, positions)
        |> assign(:url, url)
        |> assign(:user, socket.assigns.current_user)
        |> assign(:metrics, Accounts.calculate_metrics(positions))}
    else
      {:noreply,
        socket
        |> assign(:positions, nil)
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

  def handle_event("share", _, socket) do
    if socket.assigns.current_user do
      {:ok, share} = Users.create_share(socket.assigns.current_user, Enum.map(socket.assigns.positions, & &1.id))

      {:noreply,
        socket
        |> push_redirect(to: Routes.share_show_path(socket, :show, id: share.hash))}
    else
      {:noreply, socket}
    end
  end
end
