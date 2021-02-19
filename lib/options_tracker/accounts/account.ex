defmodule OptionsTracker.Accounts.Account do
  use Ecto.Schema
  import Ecto.Changeset
  use OptionsTracker.Enum

  defenum TypeEnum, tasty_works: 0, robinhood: 1, other: 1000 do
    @spec name_for(:robinhood | :tasty_works | any) :: String.t() | nil
    def name_for(:tasty_works), do: "TastyWorks"
    def name_for(:robinhood), do: "Robinhood"
    def name_for(_other), do: nil
  end

  schema "accounts" do
    field :cash, :decimal
    field :exercise_fee, :decimal
    field :name, :string
    field :broker_name, :string
    field :opt_close_fee, :decimal
    field :opt_open_fee, :decimal
    field :stock_close_fee, :decimal
    field :stock_open_fee, :decimal
    field :type, TypeEnum
    field :public, :boolean, default: false

    belongs_to :user, OptionsTracker.Users.User

    timestamps()
  end

  @required_fields ~w[name type opt_open_fee opt_close_fee stock_open_fee stock_close_fee exercise_fee cash user_id]a
  @optional_fields ~w[broker_name public]a
  @fields @required_fields ++ @optional_fields
  @spec create_changeset(Account.t(), %{optional(String.t()) => String.t() | number}) ::
          Ecto.Changeset.t()
  @doc false
  def create_changeset(account, attrs) do
    account
    |> cast(prepare_attrs(attrs), @fields)
    |> cast_broker_name(attrs)
    |> validate_required(@required_fields)
  end

  @spec changeset(Account.t(), %{optional(String.t()) => String.t() | number}) ::
          Ecto.Changeset.t()
  @doc false
  def changeset(account, attrs) do
    account
    |> cast(prepare_attrs(attrs), @fields)
    |> cast_broker_name(attrs)
    |> validate_required(@required_fields)
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
