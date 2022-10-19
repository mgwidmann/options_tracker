defmodule OptionsTracker.Audits.Position do
  use Ecto.Schema
  import Ecto.Changeset

  defmodule ActionType do
    @enum [update: 0, insert: 1, delete: 2]
    use EctoEnum, @enum

    for {type, value} <- @enum do
      def unquote(:"#{type}")(), do: unquote(value)
      def unquote(:"#{type}_key")(), do: unquote(type)
    end
  end

  schema "positions_audit" do
    field :action, ActionType
    field :before, :map

    belongs_to :user, OptionsTracker.Users.User
    belongs_to :position, OptionsTracker.Accounts.Position
    belongs_to :account, OptionsTracker.Accounts.Account

    timestamps()
  end

  @fields ~w[action before position_id account_id]a
  @spec changeset(
          {map, map} | %{:__struct__ => atom | %{__changeset__: map}, optional(atom) => any},
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  def changeset(position_audit, attrs) do
    position_audit
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end
end
