defmodule OptionsTracker.Users.Share do
  use Ecto.Schema
  import Ecto.Changeset
  alias OptionsTracker.Users.User
  alias OptionsTracker.Accounts.Position

  @derive {Jason.Encoder, except: [:__meta__]}
  schema "shares" do
    field :hash, :string

    belongs_to :user, User
    many_to_many :positions, Position, join_through: "positions_shares", on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(share, %{user: user, position_ids: position_ids}) do
    hash = calculate_hash(position_ids)

    share
    |> cast(%{hash: hash, user_id: user.id}, [:hash, :user_id])
    |> put_assoc(:user, user)
    |> validate_required([:hash, :user_id])
    |> validate_minimum_positions(position_ids)
  end

  @random_byte_length 64
  defp calculate_hash(position_ids) do
    random_bytes = :crypto.strong_rand_bytes(@random_byte_length) |> Base.url_encode64() |> binary_part(0, @random_byte_length)
    hash_input = "#{position_ids |> Enum.join("-")}|#{random_bytes}"
    salt = Application.get_env(:options_tracker, :share_salt) || raise("Missing SHARE_SALT env var configuration!")

    Bcrypt.Base.hash_password(hash_input, salt)
  end

  @spec validate_minimum_positions(Ecto.Changeset.t(__MODULE__), list(non_neg_integer())) :: Ecto.Changeset.t(__MODULE__)
  def validate_minimum_positions(changeset, []) do
    validate_change(changeset, :hash, fn _, _hash ->
      [{:hash, "must share at least one position"}]
    end)
  end

  def validate_minimum_positions(changeset, _), do: changeset
end
