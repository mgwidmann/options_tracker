defmodule OptionsTrackerWeb.PositionLive.Index do
  use OptionsTrackerWeb, :live_view
  import OptionsTrackerWeb.PositionLive.Helpers

  alias OptionsTracker.Accounts
  alias OptionsTracker.Accounts.Position

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :positions, list_positions())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Position")
    |> assign(:position, Accounts.get_position!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Position")
    |> assign(:position, %Position{account_id: 2})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Positions")
    |> assign(:position, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    position = Accounts.get_position!(id)
    {:ok, _} = Accounts.delete_position(position)

    {:noreply, assign(socket, :positions, list_positions())}
  end

  defp list_positions do
    Accounts.list_positions()
  end
end
