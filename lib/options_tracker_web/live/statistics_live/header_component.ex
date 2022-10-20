defmodule OptionsTrackerWeb.StatisticsLive.HeaderComponent do
  use OptionsTrackerWeb, :live_component

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end
end
