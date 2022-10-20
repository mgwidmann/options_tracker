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
     |> assign(:changeset, changeset)
     |> assign(:return_to, Routes.position_account_index_path(socket, :index, current_account))}
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

  @impl true
  def render(assigns) do
    if assigns[:mobile] do
      ~H"""
      <div class="card">
        <%= hidden_input @f, :account_id, value: @account_id %>
        <%= hidden_input @f, :return_to, value: @return_to, name: "return_to" %>
        <div class="card-content">
          <div class="media">
            <div class="media-left">
              <div class="field is-horizontal">
                <div class="field-body">
                  <div class="field">
                    <p class="control is-expanded input-super-small">
                      <%= number_input @f, :count, class: "input is-small input-super-small", placeholder: "1" %>
                      <%= if(@f, do: error_tag(@f, :count), else: nil) %>
                    </p>
                  </div>
                  <div class="field">
                    <p class="control is-expanded has-icons-left has-icons-right">
                      <%= text_input @f, :stock, class: "input is-rounded is-small input-super-small", id: "position_stock_mobile", placeholder: "Ticker", "phx-hook": "AddPosition" %>
                      <span class="icon is-small is-left">
                        <i class="fa fa-line-chart" aria-hidden="true"></i>
                      </span>
                      <%= if(@f, do: error_tag(@f, :stock), else: nil) %>
                    </p>
                  </div>
                </div>
              </div>
            </div>
            <div class="media-content columns">
              <div class="column">
                <div class="control has-icons-left">
                  <%= number_input @f, :strike, step: "any", class: "input is-small", placeholder: if(is_option?(@f), do: "Strike", else: "Price") %>
                  <span class="icon is-small is-left">
                    <i class="fa fa-usd"></i>
                  </span>
                  <%= if(@f, do: error_tag(@f, :strike), else: nil) %>
                </div>
              </div>
              <div class="column">
                <%= custom_radio_button @f, :short, "Sell", "Buy", id: :short_mobile, flip: true %>
              </div>
              <div class="column">
                <%= select @f, :type, position_type_map(), prompt: "Type", class: "select" %>
                <%= if(@f, do: error_tag(@f, :type), else: nil) %>
              </div>
              <%= if is_spread?(@f) do %>
                <div class="column">
                  <div class="control has-icons-left">
                    <%= number_input @f, :spread_width, step: "0.50", class: "input is-small", placeholder: "Width" %>
                    <span class="icon is-small is-left">
                      <i class="fa fa-usd"></i>
                    </span>
                    <%= if(@f, do: error_tag(@f, :spread_width), else: nil) %>
                  </div>
                </div>
              <% end %>
              <%= if !is_option?(@f) do %>
                <div class="column">
                  <div class="control has-icons-left">
                    <%= number_input @f, :basis, step: "any", class: "input is-small", placeholder: "Basis" %>
                    <span class="icon is-small is-left">
                      <i class="fa fa-usd"></i>
                    </span>
                    <%= if(@f, do: error_tag(@f, :basis), else: nil) %>
                  </div>
                </div>
              <% end %>
            </div>
          </div>
          <div class="content">
            <div class="rows">
              <div class="row">
                <div class="columns">
                  <%= if is_option?(@f) do %>
                    <div class="column">
                      <div class="control">
                        <div class="field">
                          <%= label @f, :premium, class: "label" %>
                          <p class="control has-icons-left">
                            <%= number_input @f, :premium, step: "0.01", placeholder: "0.00", class: "input is-small", disabled: !is_option?(@f) %>
                            <span class="icon is-small is-left">
                              <i class="fa fa-usd"></i>
                            </span>
                            <%= if(@f, do: error_tag(@f, :premium), else: nil) %>
                          </p>
                        </div>
                      </div>
                    </div>
                  <% end %>
                  <%= if is_option?(@f) do %>
                    <div class="column">
                      <div class="control">
                        <%= label @f, :expires_at, class: "label" %>
                        <%= text_input @f, :expires_at, type: :date, class: "input is-small date", disabled: !is_option?(@f) %>
                        <%= if(@f, do: error_tag(@f, :expires_at), else: nil) %>
                      </div>
                    </div>
                  <% end %>
                  <div class="column">
                    <%= label @f, :status, class: "label" %>
                    <%= position_status_display(Map.get(@f.data, :type), Map.get(@f.data, :status), true) %>
                  </div>
                </div>
              </div>
              <div class="row">
                <div class="columns">
                  <div class="column">
                    <div class="control">
                      <%= label @f, :opened_at, class: "label" %>
                      <%= text_input @f, :opened_at, type: :date, class: "input is-small date" %>
                      <%= if(@f, do: error_tag(@f, :opened_at), else: nil) %>
                    </div>
                  </div>
                  <div class="column">
                    <div class="control">
                      <div class="field">
                        <%= label @f, :fees, class: "label" %>
                        <p class="control has-icons-left">
                          <%= number_input @f, :fees, step: "any", class: "input is-small", value: format_currency(@f.source, :fees) %>
                          <span class="icon is-small is-left">
                            <i class="fa fa-usd"></i>
                          </span>
                          <%= if(@f, do: error_tag(@f, :fees), else: nil) %>
                        </p>
                      </div>
                    </div>
                  </div>
                  <div class="column">
                    <%#= raw Recaptcha.Template.display(size: "invisible") %>
                    <label class="label">&nbsp;</label>
                    <div class="control is-grouped has-text-centered ml-auto">
                      <%= live_patch "Cancel", to: Routes.position_index_path(@socket, :index), class: "button mx-2" %>
                      <%= submit "Save", phx_disable_with: "Saving...", class: "button is-success" %>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      """
    else
      ~H"""
      <tr id={"position-#{@position.id}"}>
        <td>
          <%= hidden_input @f, :account_id, value: @account_id %>
          <%= hidden_input @f, :return_to, value: @return_to, name: "return_to" %>
          <div class="control">
            <%= text_input @f, :opened_at, type: :date, class: "input is-small date" %>
            <%= if(@f, do: error_tag(@f, :opened_at), else: nil) %>
          </div>
        </td>
        <td>
          <span class="control px-1">
            <%= number_input @f, :count, class: "input is-small input-super-small", placeholder: "1" %>
            <%= if(@f, do: error_tag(@f, :count), else: nil) %>
          </span>
        </td>
        <td>
          <div class="control">
            <div class="field">
              <p class="control has-icons-left is-inline">
                <%= text_input @f, :stock, class: "input is-rounded is-small is-inline", id: "position_stock", placeholder: "Ticker", "phx-hook": "AddPosition" %>
                <span class="icon is-small is-left">
                  <i class="fa fa-line-chart" aria-hidden="true"></i>
                </span>
                <%= if(@f, do: error_tag(@f, :stock), else: nil) %>
              </p>
            </div>
          </div>
        </td>
        <td>
          <%= custom_radio_button @f, :short, "Sell", "Buy", id: :short_desktop, flip: true %>
        </td>
        <td>
          <div class="control has-icons-left">
            <div class="field">
              <p class="control has-icons-left">
                <%= number_input @f, :strike, step: "any", class: "input is-small", placeholder: if(is_option?(@f), do: "Strike", else: "Price") %>
                <span class="icon is-small is-left">
                  <i class="fa fa-usd"></i>
                </span>
                <%= if(@f, do: error_tag(@f, :strike), else: nil) %>
              </p>
            </div>
          </div>
        </td>
        <td>
          <p class="control">
            <span>
              <%= select @f, :type, position_type_map(), prompt: "Type", class: "select" %>
            </span>
            <%= if(@f, do: error_tag(@f, :type), else: nil) %>
          </p>
          <%= if is_spread?(@f) do %>
            <p class="control has-icons-left mt-1">
              <%= number_input @f, :spread_width, step: "0.50", class: "input is-small", placeholder: "Width" %>
              <span class="icon is-small is-left">
                <i class="fa fa-usd"></i>
              </span>
              <%= if(@f, do: error_tag(@f, :spread_width), else: nil) %>
            </p>
          <% end %>
          <%= if !is_option?(@f) do %>
            <p class="control has-icons-left mt-1">
              <%= number_input @f, :basis, step: "any", class: "input is-small", placeholder: "Basis" %>
              <span class="icon is-small is-left">
                <i class="fa fa-usd"></i>
              </span>
              <%= if(@f, do: error_tag(@f, :basis), else: nil) %>
            </p>
          <% end %>
        </td>
        <td>
          <%= if is_option?(@f) do %>
            <div class="control">
              <%= text_input @f, :expires_at, type: :date, class: "input is-small date"  %>
              <%= if(@f, do: error_tag(@f, :expires_at), else: nil) %>
            </div>
          <% end %>
        </td>
        <td>
          <%= if is_option?(@f) do %>
            <div class="control">
              <div class="field">
                <p class="control has-icons-left">
                  <%= number_input @f, :premium, step: "0.01", placeholder: "0.00", class: "input is-small", disabled: !is_option?(@f)  %>
                  <span class="icon is-small is-left">
                    <i class="fa fa-usd"></i>
                  </span>
                  <%= if(@f, do: error_tag(@f, :premium), else: nil) %>
                </p>
              </div>
            </div>
          <% end %>
        </td>
        <td>
          <div class="control">
            <div class="field">
              <p class="control">
                <%= position_status_display(Map.get(@f.data, :type), Map.get(@f.data, :status), true) %>
              </p>
            </div>
            <%= if(@f, do: error_tag(@f, :status), else: nil) %>
          </div>
        </td>
        <td></td>
        <td>
          <div class="control">
            <div class="field">
              <p class="control has-icons-left">
                <%= number_input @f, :fees, step: "any", class: "input is-small", value: format_currency(@f.source, :fees) %>
                <span class="icon is-small is-left">
                  <i class="fa fa-usd"></i>
                </span>
                <%= if(@f, do: error_tag(@f, :fees), else: nil) %>
              </p>
            </div>
          </div>
        </td>
        <td>
          <div class="control is-grouped is-pulled-right ml-auto">
            <a href="#" class="button mx-2" phx-click="cancel">Cancel</a>
            <%= raw Recaptcha.Template.display(size: "invisible") %>
            <%= submit "Save", phx_disable_with: "Saving...", class: "button is-success" %>
          </div>
        </td>
      </tr>
      """
    end
  end
end
