defmodule OptionsTrackerWeb.ModalComponent do
  use OptionsTrackerWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""
    <div class="modal is-active is-clipped" id="<%= @id %>">
      <div class="modal-background"></div>
      <div class="modal-card">
        <header class="modal-card-header">
          <p class="modal-card-title"><%= @modal_title %></p>
          <button type="button" class="delete" aria-label="close">
            <%= live_patch raw("&times;"), to: @return_to, "aria-hidden": true %>
          </button>
        </header>
        <section class="modal-card-body">
          <%= live_component @socket, @component, @opts %>
        </section>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end
end
