defmodule OptionsTrackerWeb.ModalComponent do
  use OptionsTrackerWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""
    <div class="modal is-active is-clipped" id="<%= @id %>" phx-keyup="close" phx-target="#<%= @id %>">
      <div class="modal-background" phx-capture-click="close" phx-target="#<%= @id %>" phx-page-loading></div>
      <div class="modal-card">
        <header class="modal-card-head">
          <p class="modal-card-title"><%= @modal_title %></p>
          <button type="button" class="delete" aria-label="close" phx-capture-click="close" phx-target="#<%= @id %>">
            <%= live_patch raw("&times;"), to: @return_to, "aria-hidden": true %>
          </button>
        </header>
        <section class="modal-card-body">
          <%= live_component @socket, @component, @opts %>
        </section>
        <footer class="modal-card-foot">
          <button class="button is-success">Save changes</button>
          <button class="button">Cancel</button>
        </footer>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end
end
