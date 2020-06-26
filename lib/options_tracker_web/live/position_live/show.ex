defmodule OptionsTrackerWeb.PositionLive.Show do
  use OptionsTrackerWeb, :live_view

  alias OptionsTracker.Accounts

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:position, Accounts.get_position!(id))}
  end

  defp page_title(:show), do: "Show Position"
  defp page_title(:edit), do: "Edit Position"
end
