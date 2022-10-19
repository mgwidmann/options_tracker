defmodule OptionsTracker.Cleaner do
  import Ecto.Query
  alias OptionsTracker.Repo

  @day 24 * 60 * 60

  def clean(schema, days_to_keep) do
    datetime = NaiveDateTime.utc_now() |> NaiveDateTime.add(-days_to_keep * @day, :second)
    from(t in schema, where: t.inserted_at <= ^datetime)
    |> Repo.delete_all()
  end
end
