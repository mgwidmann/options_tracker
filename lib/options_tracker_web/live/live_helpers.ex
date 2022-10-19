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
    on_close = Keyword.get(opts, :on_close, fn -> nil end)

    modal_opts = [
      id: :modal,
      return_to: path,
      component: component,
      modal_title: opts[:modal_title] || "Modal Title",
      on_close: on_close,
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

  def percentage_string(float) when is_float(float) do
    float
    |> Decimal.from_float()
    |> percentage_string()
  end

  def percentage_string(%Decimal{} = decimal) do
    if Decimal.inf?(decimal) do
      "Undefined"
    else
      decimal
      |> Decimal.mult(100)
      |> Decimal.round(2)
      |> Decimal.to_string()
      |> Kernel.<>("%")
    end
  end

  def ensure_decimal(""), do: Decimal.from_float(0.0)
  def ensure_decimal(string) when is_bitstring(string) do
    case Float.parse(string) do
      {float, remaining} when remaining in ["", "."] ->
        Decimal.from_float(float)
      :error ->
        raise "Failure to ensure_decimal, decimal (#{inspect string}) could not be parsed."
    end
  end

  def ensure_decimal(%Decimal{} = decimal), do: decimal

  def ensure_date(""), do: Date.utc_today()
  def ensure_date(string) when is_bitstring(string) do
    case DateTimeParser.parse(string) do
      {:ok, date} ->
        date

      {:error, reason} ->
        raise "Failure to ensure_date, date (#{inspect string}) could not be parsed: #{reason}"
    end
  end

  def ensure_date(%Date{} = date), do: date

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

    current_user
  end

  def custom_radio_button(socket, form, name, negative_label, positive_label, opts \\ []) do
    live_component socket, OptionsTrackerWeb.Components.RadioButtonComponent,
      id: opts[:id] || name,
      f: form,
      name: name,
      negative_label: negative_label,
      positive_label: positive_label,
      flip: if(opts[:flip] == nil, do: false, else: opts[:flip])
  end
end
