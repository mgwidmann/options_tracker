defmodule OptionsTracker.Users.Feedback do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Inspect, []}
  schema "feedback" do
    field :rating, :integer
    field :text, :string
    field :path, :string
    field :read, :boolean
    field :response, :string

    belongs_to :user, OptionsTracker.Users.User

    timestamps()
  end

  @fields ~w[rating text path read response user_id]a
  @required ~w[rating text path user_id]a
  @spec changeset(Feedback.t(), %{optional(String.t()) => String.t() | number}) ::
          Ecto.Changeset.t()
  @doc false
  def changeset(feedback, attrs) do
    feedback
    |> cast(attrs, @fields)
    |> validate_required(@required)
  end
end
