defmodule OptionsTrackerWeb.StatisticsLive.HeaderComponent do
  use OptionsTrackerWeb, :live_component
  import OptionsTrackerWeb.PositionLive.Helpers

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end
end
