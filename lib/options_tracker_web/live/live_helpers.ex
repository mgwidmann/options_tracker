defmodule OptionsTrackerWeb.LiveHelpers do
  import Phoenix.LiveView.Helpers

  @doc """
  Renders a component inside the `OptionsTrackerWeb.ModalComponent` component.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <%= live_modal @socket, OptionsTrackerWeb.UserLive.FormComponent,
        id: @user.id || :new,
        action: @live_action,
        user: @user,
        return_to: Routes.user_index_path(@socket, :index) %>
  """
  def live_modal(socket, component, opts) do
    path = Keyword.fetch!(opts, :return_to)

    modal_opts = [
      id: :modal,
      return_to: path,
      component: component,
      modal_title: opts[:modal_title] || "Modal Title",
      opts: opts
    ]

    live_component(socket, OptionsTrackerWeb.ModalComponent, modal_opts)
  end

  @spec currency_string(float | Decimal.t(), boolean) :: String.t()
  def currency_string(float_or_decimal, prepend_unit \\ true, is_input \\ false)

  def currency_string(float, prepend_unit, is_input) when is_float(float) do
    float
    |> Decimal.from_float()
    |> currency_string(prepend_unit, is_input)
  end

  def currency_string(%Decimal{} = decimal, prepend_unit, is_input) do
    if Decimal.inf?(decimal) do
      "Infinity"
    else
      decimal
      |> Decimal.mult(100)
      |> Decimal.round()
      |> Decimal.to_integer()
      |> Money.new()
      |> Money.to_string(symbol: prepend_unit, separator: if(is_input, do: "", else: ","))
    end
  end

  @spec format_currency(Ecto.Changeset.t(), atom) :: String.t() | nil
  def format_currency(%Ecto.Changeset{} = changeset, field) do
    value = changeset.changes[field] || Map.get(changeset.data, field)

    if value do
      currency_string(value, false, true)
    end
  end

  def format_currency(nil, _field) do
    nil
  end

  def track(current_user) do
    OptionsTrackerWeb.Presence.track(
      self(),
      "users",
      current_user.id,
      %{
        email: current_user.email,
        user_id: current_user.id
      }
    )
  end
end
