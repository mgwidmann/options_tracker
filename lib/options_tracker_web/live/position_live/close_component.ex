defmodule OptionsTrackerWeb.PositionLive.CloseComponent do
  use OptionsTrackerWeb, :live_component
  import OptionsTrackerWeb.PositionLive.Helpers

  alias OptionsTracker.Accounts

  @impl true
  def update(%{position: position} = assigns, socket) do
    changeset = Accounts.change_position(position)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"position" => position_params}, socket) do
    changeset =
      socket.assigns.position
      |> Accounts.change_position(Enum.into(%{status: :closed, closed_at: DateTime.utc_now()}, position_params))
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"position" => position_params}, socket) do
    save_position(socket, socket.assigns.action, position_params)
  end

  defp save_position(socket, :close, position_params) do
    case Accounts.update_position(socket.assigns.position, position_params |> IO.inspect) do
      {:ok, _position} ->
        {:noreply,
         socket
         |> put_flash(:info, "Position closed successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(changeset)
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end