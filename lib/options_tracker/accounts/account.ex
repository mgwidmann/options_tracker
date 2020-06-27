defmodule OptionsTracker.Accounts.Account do
  use Ecto.Schema
  import Ecto.Changeset

  defmodule TypeEnum do
    use EctoEnum, tasty_works: 0, robinhood: 1, td_ameritrade: 2, other: 1000

    @spec name_for(:robinhood | :tasty_works | :td_ameritrade | any) :: String.t() | nil
    def name_for(:tasty_works), do: "TastyWorks"
    def name_for(:robinhood), do: "Robinhood"
    def name_for(:td_ameritrade), do: "TD Ameritrade"
    def name_for(_other), do: nil
  end

  schema "accounts" do
    field :cash, :decimal
    field :exercise_fee, :float
    field :name, :string
    field :broker_name, :string
    field :opt_close_fee, :float
    field :opt_open_fee, :float
    field :stock_close_fee, :float
    field :stock_open_fee, :float
    field :type, TypeEnum

    belongs_to :user, OptionsTracker.Users.User

    timestamps()
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(prepare_attrs(attrs), [
      :name,
      :broker_name,
      :type,
      :opt_open_fee,
      :opt_close_fee,
      :stock_open_fee,
      :stock_close_fee,
      :exercise_fee,
      :cash
    ])
    |> cast_broker_name(attrs)
    |> validate_required([
      :name,
      :type,
      :opt_open_fee,
      :opt_close_fee,
      :stock_open_fee,
      :stock_close_fee,
      :exercise_fee,
      :cash
    ])
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

  defp cast_broker_name(changeset, params) do
    case get_field(changeset, :type) do
      :other ->
        cast(changeset, params, [:broker_name], [])
        |> validate_required([:broker_name])

      _ ->
        changeset
    end
  end
end
