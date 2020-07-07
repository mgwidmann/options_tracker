defmodule OptionsTrackerWeb.PositionLive.DeleteModalComponent do
  use OptionsTrackerWeb, :live_component

  @impl true
  def update(assigns, socket) do
    {:ok, socket |> assign(assigns)}
  end
end
