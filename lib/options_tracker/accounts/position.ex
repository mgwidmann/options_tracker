defmodule OptionsTracker.Accounts.Position do
  use Ecto.Schema
  import Ecto.Changeset

  defmodule TransType do
    use EctoEnum, stock: 0, call: 1, put: 2
    def name_for(:stock), do: "Stock"
    def name_for(:call), do: "Call"
    def name_for(:put), do: "Put"
  end

  defmodule StatusType do
    use EctoEnum, open: 0, closed: 1, rolled: 2, exercised: 3
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
    field :fees, :float
    field :spread_width, :float

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

  @required_open_fields ~w[stock short type strike opened_at expires_at premium fees status]a
  @optional_open_fields ~w[spread spread_width notes exit_strategy]a
  @open_fields @required_open_fields ++ @optional_open_fields
  @spec open_changeset(
          {map, map} | %{:__struct__ => atom | %{__changeset__: map}, optional(atom) => any},
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  @doc false
  def open_changeset(position, attrs) do
    attrs = Map.put(attrs, "status", :open)

    position
    |> cast(prepare_attrs(attrs), @open_fields)
    |> validate_required(@required_open_fields)
    |> validate_position_open()
    |> standard_validations()
  end

  defp validate_position_open(%{data: %{id: nil}} = changeset), do: changeset
  defp validate_position_open(changeset) do
    changeset
    |> add_error(:id, "Cannot perform operation to open on an existing position. This is a bug.")
  end

  defp prepare_attrs(%{"type" => "" <> _ = type} = attrs) do
    case Integer.parse(type) do
      {type_int, ""} ->
        Map.put(attrs, "type", type_int)
      :error ->
        attrs
    end
  end
  defp prepare_attrs(attrs), do: attrs

  @fields @open_fields ++ ~w[basis fees exit_price closed_at profit_loss]a
  @spec changeset(
          {map, map} | %{:__struct__ => atom | %{__changeset__: map}, optional(atom) => any},
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  def changeset(position, attrs) do
    position
    |> cast(prepare_attrs(attrs), @fields)
    |> standard_validations()
    |> validate_number(:basis, greater_than: 0.0)
  end

  defp standard_validations(changeset) do
    changeset
    |> validate_length(:stock, min: 1)
    |> validate_number(:premium, greater_than: 0.0)
    |> validate_number(:strike, greater_than: 0.0)
    |> validate_number(:fees, greater_than: 0.0)
    |> validate_number(:exit_price, greater_than: 0.0)
    |> validate_length(:notes, max: 10_000)
    |> validate_length(:exit_strategy, max: 10_000)
  end
end
