defmodule OptionsTrackerWeb.FeedbackLive.FormComponent do
  use OptionsTrackerWeb, :live_component
  alias OptionsTracker.Users
  alias OptionsTracker.Users.Feedback

  @impl true

  @spec update(%{}, Phoenix.LiveView.Socket.t()) :: {:ok, Phoenix.LiveView.Socket.t()}
  def update(%{changeset: changeset}, socket) do
    {:ok,
     socket
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"feedback" => params}, socket) do
    changeset = Users.change_feedback(%Feedback{}, params)

    {:noreply,
     socket
     |> assign(:changeset, changeset)}
  end

  def handle_event("save", %{"feedback" => params}, socket) do
    case Users.create_feedback(params) do
      {:ok, feedback} ->
        {:noreply,
         socket
         |> put_flash(:info, "Feedback submitted successfully!")
         |> push_redirect(to: feedback.path)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  @spec rating_colored?(%{params: %{String.t() => String.t()}}, 1..5) :: boolean
  for i <- 1..5, j <- 1..5 do
    def rating_colored?(%{params: %{"rating" => unquote(to_string(i))}}, unquote(j)) do
      unquote(i >= j)
    end
  end

  def rating_colored?(_, _), do: false
end
