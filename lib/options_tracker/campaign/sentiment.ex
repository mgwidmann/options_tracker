defmodule OptionsTracker.Campaign.Sentiment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sentiment" do
    field :answer, :string
    field :campaign, :string

    belongs_to :user, OptionsTracker.Users.User

    timestamps()
  end

  @doc false
  def changeset(sentiment, attrs) do
    sentiment
    |> cast(attrs, [:campaign, :answer, :user_id])
    |> validate_required([:campaign, :answer, :user_id])
  end
end
