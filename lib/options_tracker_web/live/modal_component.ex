defmodule OptionsTrackerWeb.ModalComponent do
  use OptionsTrackerWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="modal is-active is-clipped" id={@id} phx-keyup="close" phx-target={"##{@id}"}>
      <div class="modal-background" phx-capture-click="close" phx-target={"##{@id}"} phx-page-loading></div>
      <div class="modal-card wide">
        <header class="modal-card-head">
          <p class="modal-card-title"><%= @modal_title %></p>
          <button type="button" class="delete" aria-label="close" phx-capture-click="close" phx-target={"##{@id}"}>
            <%= live_patch raw("&times;"), to: @return_to, "aria-hidden": true %>
          </button>
        </header>
        <%= live_component @component, @opts %>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("close", _, socket) do
    if socket.assigns[:on_close] do
      socket.assigns.on_close.()
    end

    {:noreply,
     socket
     |> push_patch(to: socket.assigns.return_to)}
  end
end
