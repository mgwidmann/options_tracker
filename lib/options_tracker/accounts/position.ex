defmodule OptionsTracker.Accounts.Position do
  use Ecto.Schema
  import Ecto.Changeset
  import OptionsTracker.Utilities.Maps

  defmodule TransType do
    use EctoEnum, stock: 0, call: 1, put: 2
    @spec name_for(:call | :put | :stock) :: String.t()
    def name_for(:stock), do: "Stock"
    def name_for(:call), do: "Call"
    def name_for(:put), do: "Put"
  end

  defmodule StatusType do
    use EctoEnum, open: 0, closed: 1, rolled: 2, exercised: 3
    @spec name_for(:closed | :open | :rolled, boolean) :: String.t()
    def name_for(status, past_tense)
    def name_for(:open, false), do: "Open"
    def name_for(:open, true), do: "Opened"
    def name_for(:closed, false), do: "Close"
    def name_for(:closed, true), do: "Closed"
    def name_for(:rolled, false), do: "Roll"
    def name_for(:rolled, true), do: "Rolled"
    def name_for(:exercised, false), do: "Exercise"
    def name_for(:exercised, true), do: "Exercised"
  end

  schema "positions" do
    # Require info on open
    field :stock, :string
    field :strike, :float
    field :short, :boolean
    field :spread, :boolean
    field :type, TransType
    field :opened_at, :utc_datetime
    field :premium, :float
    field :expires_at, :utc_datetime
    field :fees, :float, default: 0.00
    field :spread_width, :float
    field :count, :integer, default: 1

    # Updated later
    field :basis, :float
    field :closed_at, :utc_datetime
    field :profit_loss, :float
    field :status, StatusType
    field :exit_price, :float

    field :notes, :string
    field :exit_strategy, :string

    belongs_to :account, OptionsTracker.Accounts.Account

    timestamps()
  end

  @required_open_fields ~w[stock short type strike opened_at expires_at premium fees status count account_id]a
  @not_allowed_stock_fields ~w[expires_at premium spread spread_width]a
  @not_allowed_option_fields ~w[basis]a
  @optional_open_fields ~w[spread spread_width basis notes exit_strategy]a
  @open_fields @required_open_fields ++ @optional_open_fields
  @spec open_changeset(
          {map, map} | %{:__struct__ => atom | %{__changeset__: map}, optional(atom) => any},
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  @doc false
  def open_changeset(position, attrs) do
    attrs =
      attrs
      |> stringify_keys()
      |> Map.put("status", :open)
      |> prepare_attrs()

    if attrs["type"] in [:stock, "stock", 0] do
      # Set the basis to the stock price if its not filled in
      attrs = Map.put(attrs, "basis", Map.get(attrs, "basis", attrs["strike"]))

      position
      |> cast(attrs, @open_fields -- @not_allowed_stock_fields)
      |> validate_required(@required_open_fields -- @not_allowed_stock_fields)
      |> validate_position_open()
      |> standard_validations()
    else
      position
      |> cast(prepare_attrs(attrs), @open_fields -- @not_allowed_option_fields)
      |> validate_required(@required_open_fields -- @not_allowed_option_fields)
      |> validate_position_open()
      |> standard_validations()
    end
  end

  defp validate_position_open(%{data: %{id: nil}} = changeset), do: changeset

  defp validate_position_open(changeset) do
    changeset
    |> add_error(:id, "Cannot perform operation to open on an existing position. This is a bug.")
  end

  defp prepare_attrs(attrs) do
    Enum.reduce(["type", "status"], attrs, fn key, attrs ->
      value = attrs[key]
      if value && is_binary(value) do
        case Integer.parse(value) do
          {int, ""} ->
            Map.put(attrs, key, int)

          :error ->
            attrs
        end
      else
        attrs
      end
    end)
  end

  @immutable_fields ~w[stock short type strike opened_at expires_at premium]a
  @fields (@open_fields ++ ~w[basis fees exit_price closed_at]a) -- @immutable_fields
  @spec changeset(
          {map, map} | %{:__struct__ => atom | %{__changeset__: map}, optional(atom) => any},
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  def changeset(position, attrs) do
    attrs =
      attrs
      |> stringify_keys()
      |> prepare_attrs()

    if position.type in [:stock, "stock", 0] do
      position
      |> cast(prepare_attrs(attrs), @fields -- @not_allowed_stock_fields)
      |> validate_required(@required_open_fields -- @not_allowed_stock_fields)
      |> standard_validations()
      |> validate_number(:basis, greater_than: 0.0)
      |> calculate_profit_loss()
    else
      position
      |> cast(prepare_attrs(attrs), @fields -- @not_allowed_option_fields)
      |> validate_required(@required_open_fields -- @not_allowed_option_fields)
      |> standard_validations()
      |> calculate_profit_loss()
    end
  end

  defp standard_validations(changeset) do
    changeset
    |> foreign_key_constraint(:account_id)
    |> validate_length(:stock, min: 1)
    |> upcase_stock()
    |> validate_number(:premium, [])
    |> validate_number(:strike, greater_than: 0.0)
    |> validate_number(:fees, greater_than_or_equal_to: 0.0)
    |> validate_number(:exit_price, greater_than_or_equal_to: 0.0)
    |> validate_length(:notes, max: 10_000)
    |> validate_length(:exit_strategy, max: 10_000)
  end

  defp calculate_profit_loss(changeset) do
    premium = get_field(changeset, :premium)
    status = get_change(changeset, :status)
    prior_status = changeset.data.status
    exit_price = get_field(changeset, :exit_price)
    count = get_field(changeset, :count)
    type = get_field(changeset, :type)
    strike = get_field(changeset, :strike)
    short = get_field(changeset, :short)

    if prior_status == :open && status != :open && exit_price && count do
      profit_loss =
        if type == :stock do
          (exit_price - strike) * if(short, do: -1, else: 1) * count
        else
          (premium - exit_price) * 100 * count
        end
        |> Decimal.from_float()
        |> Decimal.round(2, :half_up)
        |> Decimal.to_float()

      put_change(changeset, :profit_loss, profit_loss)
    else
      changeset
    end
  end

  defp upcase_stock(changeset) do
    stock = get_field(changeset, :stock)

    if stock && String.upcase(stock) != stock do
      put_change(changeset, :stock, String.upcase(stock))
    else
      changeset
    end
  end
end