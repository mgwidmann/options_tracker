defmodule OptionsTracker.Campaign do
  @moduledoc """
  The Campaign context.
  """

  import Ecto.Query, warn: false
  alias OptionsTracker.Repo
  alias OptionsTracker.Users.{User}
  alias OptionsTracker.Campaign.Sentiment

  @spec campaigns(User.t) :: [Sentiment.t]
  def campaigns(user) do
    from(s in Sentiment, where: s.user_id == ^user.id)
    |> Repo.all()
  end

  @spec record_campaign(User.t, String.t, String.t) :: {:ok, Sentiment.t}
  def record_campaign(%User{id: id}, campaign, answer) do
    Sentiment.changeset(%Sentiment{}, %{user_id: id, campaign: campaign, answer: answer})
    |> Repo.insert()
  end
end
