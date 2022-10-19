defmodule OptionsTrackerWeb.FeedbackLive.FeedbackEntry do
  use OptionsTrackerWeb, :live_component
  alias OptionsTracker.Users.Feedback

  @impl true

  @spec update(%{}, Phoenix.LiveView.Socket.t()) :: {:ok, Phoenix.LiveView.Socket.t()}
  def update(%{current_user: _, path: _} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, nil)}
  end

  def update(%{changeset: nil}, socket) do
    {:ok,
     socket
     |> assign(:changeset, nil)}
  end

  @impl true
  def handle_event("open", _params, socket) do
    changeset =
      Feedback.changeset(%Feedback{}, %{
        user_id: socket.assigns.current_user.id,
        path: socket.assigns.path
      })

    {:noreply,
     socket
     |> assign(:changeset, changeset)}
  end

  def handle_event("close", _params, socket) do
    {:noreply,
     socket
     |> assign(:changeset, nil)}
  end
end
