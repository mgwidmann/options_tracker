defmodule OptionsTrackerWeb.PositionLive.EditModalComponent do
  use OptionsTrackerWeb, :live_component
  import OptionsTrackerWeb.PositionLive.Helpers

  alias OptionsTracker.Accounts

  @impl true
  def update(%{position: position, action: action} = assigns, socket) do
    closed_at =
      if(
        position.expires_at && Timex.compare(Timex.today(), position.expires_at, :day) in [-1, 0],
        do: Timex.today(),
        else: position.expires_at
      )

    changeset =
      Accounts.change_position(
        position,
        if(action == :close, do: %{status: :closed, closed_at: closed_at}, else: %{})
      )

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"position" => position_params}, socket) do
    changeset =
      socket.assigns.position
      |> Accounts.change_position(
        Enum.into(
          %{status: :closed, closed_at: DateTime.utc_now() |> DateTime.to_date()},
          position_params
        )
      )
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"position" => position_params}, socket) do
    save_position(socket, socket.assigns.action, position_params)
  end

  defp save_position(socket, :notes, position_params) do
    case Accounts.update_position(
           socket.assigns.position,
           position_params,
           socket.assigns.current_user
         ) do
      {:ok, _position} ->
        {:noreply,
         socket
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_position(socket, :close, position_params) do
    case Accounts.update_position(
           socket.assigns.position,
           position_params,
           socket.assigns.current_user
         ) do
      {:ok, _position} ->
        {:noreply,
         socket
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end
