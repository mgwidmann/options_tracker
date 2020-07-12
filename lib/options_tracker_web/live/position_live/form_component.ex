defmodule OptionsTrackerWeb.PositionLive.FormComponent do
  use OptionsTrackerWeb, :live_component
  import OptionsTrackerWeb.PositionLive.Helpers

  alias OptionsTracker.Accounts

  @impl true
  @spec update(
          %{account_id: non_neg_integer(), position: OptionsTracker.Accounts.Position.t()},
          Phoenix.LiveView.Socket.t()
        ) :: {:ok, Phoenix.LiveView.Socket.t()}
  def update(%{position: position, account_id: account_id} = assigns, socket) do
    current_account = Map.get_lazy(socket.assigns, :current_account, fn -> Accounts.get_account!(account_id) end)

    changeset = Accounts.change_position(position)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:current_account, current_account)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("save", %{"position" => position_params}, socket) do
    save_position(socket, socket.assigns.action, position_params |> compact())
  end

  defp save_position(socket, :edit, position_params) do
    case Accounts.update_position(
           socket.assigns.position,
           position_params,
           socket.assigns.current_user
         ) do
      {:ok, _position} ->
        {:noreply,
         socket
         |> put_flash(:info, "Position updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_position(socket, :new, position_params) do
    case Accounts.create_position(position_params, socket.assigns.current_user) do
      {:ok, _position} ->
        {:noreply,
         socket
         |> put_flash(:info, "Position opened successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
