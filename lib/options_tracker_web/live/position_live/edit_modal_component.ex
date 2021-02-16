defmodule OptionsTrackerWeb.PositionLive.EditModalComponent do
  use OptionsTrackerWeb, :live_component
  import OptionsTrackerWeb.PositionLive.Helpers

  alias OptionsTracker.Accounts
  alias OptionsTracker.Accounts.Position
  import OptionsTracker.Accounts.Position.TransType, only: [stock?: 1]

  @seconds_in_a_day 86_400

  @impl true
  def update(%{position: position, action: action} = assigns, socket) do
    closed_at =
      if(
        position.expires_at && Timex.compare(Timex.today(), position.expires_at, :day) in [-1, 0],
        do: Timex.today(),
        else: position.expires_at || Timex.today()
      )

    position = Accounts.position_with_account(position)

    changeset =
      Accounts.change_position(
        position,
        if(action == :close || action == :roll,
          do: %{
            status: :closed,
            closed_at: closed_at,
            fees: Accounts.closing_fees(position, position.account),
            rolled_fees: if(action == :roll, do: Accounts.opening_fees(position), else: nil),
            rolled_opened_at: if(action == :roll, do: DateTime.utc_now() |> DateTime.to_date(), else: nil),
            rolled_strike: if(action == :roll, do: position.strike, else: nil),
            rolled_premium: if(action == :roll, do: position.premium, else: nil),
            rolled_expires_at: if(action == :roll, do: DateTime.utc_now() |> DateTime.add(30 * @seconds_in_a_day, :second) |> DateTime.to_date(), else: nil)
          },
          else: %{}
        )
      )

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:position, position)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"position" => position_params}, %Phoenix.LiveView.Socket{assigns: %{action: :roll}} = socket) do
    changeset =
      socket.assigns.position
      |> Accounts.roll_position(position_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

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

  defp save_position(socket, :roll, position_params) do
    duplicate = Accounts.duplicate_position(socket.assigns.position, %{
      type: socket.assigns.position.type,
      opened_at: position_params["rolled_opened_at"],
      fees: position_params["rolled_fees"],
      strike: position_params["rolled_strike"],
      premium: position_params["rolled_premium"],
      expires_at: position_params["rolled_expires_at"],
      rolled_position_id: socket.assigns.position.id,
    })
    case Accounts.update_roll_position(
           socket.assigns.position,
           position_params,
           duplicate,
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
