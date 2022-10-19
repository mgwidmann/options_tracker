defmodule OptionsTracker.Repo.Migrations.ChangeUserConfirmedAtToUtc do
  use Ecto.Migration

  def change do
    alter table(:users) do
      modify :confirmed_at, :utc_datetime, from: :naive_datetime
    end
  end
end
