defmodule OptionsTracker.Accounts.Position do
  use Ecto.Schema
  import Ecto.Changeset
  import OptionsTracker.Utilities.Maps

  defmodule TransType do
    @enum [stock: 0, call: 1, put: 2]
    use EctoEnum, @enum
    @spec name_for(:call | :put | :stock) :: String.t()
    def name_for(:stock), do: "Stock"
    def name_for(:call), do: "Call"
    def name_for(:put), do: "Put"

    for {type, value} <- @enum do
      def unquote(:"#{type}")(), do: unquote(value)
      def unquote(:"#{type}_key")(), do: unquote(type)
    end
  end

  defmodule StatusType do
    @enum [open: 0, closed: 1, rolled: 2, exercised: 3]
    use EctoEnum, @enum
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

    for {type, value} <- @enum do
      def unquote(:"#{type}")(), do: unquote(value)
      def unquote(:"#{type}_key")(), do: unquote(type)
    end
  end

  @derive {Jason.Encoder, except: [:account, :__meta__]}
  schema "positions" do
    # Require info on open
    field :stock, :string
    field :strike, :decimal
    field :short, :boolean
    field :type, TransType
    field :opened_at, OptionsTracker.Fields.Date
    field :premium, :decimal
    field :expires_at, OptionsTracker.Fields.Date
    field :fees, :decimal, default: Decimal.from_float(0.00)
    field :spread_width, :decimal
    field :count, :integer, default: 1

    # Updated later
    field :basis, :decimal
    field :closed_at, OptionsTracker.Fields.Date
    field :profit_loss, :decimal
    field :status, StatusType
    field :exit_price, :decimal

    field :notes, :string
    field :exit_strategy, :string

    belongs_to :account, OptionsTracker.Accounts.Account

    timestamps()
  end

  @required_open_fields ~w[stock short type strike opened_at expires_at premium fees status count account_id]a
  @not_allowed_stock_fields ~w[expires_at premium spread_width]a
  @not_allowed_option_fields ~w[basis]a
  @optional_open_fields ~w[spread_width basis notes exit_strategy]a
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
    # Handle integers which come in as strings
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

  @fields @open_fields ++ ~w[basis short type strike opened_at premium fees exit_price expires_at closed_at]a
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
      |> cast(attrs, @fields -- @not_allowed_stock_fields)
      |> validate_required(@required_open_fields -- @not_allowed_stock_fields)
      |> standard_validations()
      |> validate_number(:basis, greater_than: 0.0)
      |> calculate_profit_loss()
    else
      position
      |> cast(attrs, @fields -- @not_allowed_option_fields)
      |> validate_required(@required_open_fields -- @not_allowed_option_fields)
      |> standard_validations()
      |> calculate_profit_loss()
    end
  end

  def duplicate_changeset(position, attrs) do
    attrs =
      attrs
      |> stringify_keys()
      |> prepare_attrs()

    attrs =
      position
      |> to_stock_attrs()
      |> stringify_keys()
      |> Map.merge(attrs)

    %__MODULE__{}
    |> cast(attrs, @fields)
    |> standard_validations()
    |> calculate_profit_loss()
  end

  @spec open_related_positions(Position.t()) :: Ecto.Query.t()
  def open_related_positions(position) do
    import Ecto.Query

    open_enum = StatusType.open()
    stock_enum = TransType.stock()

    from(p in __MODULE__,
      where:
        p.account_id == ^position.account_id and
          p.status == ^open_enum and
          p.stock == ^position.stock and
          p.type == ^stock_enum
    )
    # Apply logic to oldest opened positions first
    |> order_by(asc: :opened_at)
  end

  @spec to_stock_attrs(Position.t()) :: %{
          account_id: any,
          count: number,
          fees: number,
          opened_at: DateTime.t(),
          short: any,
          status: :open,
          stock: any,
          strike: any,
          type: :stock
        }
  def to_stock_attrs(%__MODULE__{
        type: call_or_put,
        stock: stock,
        strike: strike,
        short: short,
        count: count,
        account: account
      })
      when call_or_put in ~w[call put]a do
    %{
      stock: stock,
      strike: strike,
      short: short,
      count: count * 100,
      type: :stock,
      opened_at: DateTime.utc_now(),
      fees: Decimal.to_float(account.stock_open_fee) * count * 100,
      status: :open,
      account_id: account.id
    }
  end

  def to_stock_attrs(%__MODULE__{type: :stock} = position) do
    position
    |> Map.from_struct()
    # Don't need relationship, just account ID
    |> Map.drop(~w[account id]a)
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
    exit_price = get_field(changeset, :exit_price)
    count = get_field(changeset, :count)
    type = get_field(changeset, :type)
    strike = get_field(changeset, :strike)
    short = get_field(changeset, :short)

    if status != :open && exit_price && count do
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
