defmodule OptionsTrackerWeb.FeedbackLive.Index do
  use OptionsTrackerWeb, :live_view
  alias OptionsTracker.Users

  @impl true
  def mount(params, %{"user_token" => user_token} = _session, socket) do
    current_user = Users.get_user_by_session_token(user_token)
    track(current_user)

    feedbacks = Users.list_feedbacks()

    {:ok,
     socket
     |> assign(:current_user, current_user)
     |> assign(:feedbacks, feedbacks)}
  end

  @impl true
  def handle_params(params, url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    feedback = Users.get_feedback!(id)

    if socket.assigns.current_user.admin? do
      {:ok, _} = Users.delete_feedback(feedback)
    end

    {:noreply, assign(socket, :feedbacks, Users.list_feedbacks())}
  end
end
