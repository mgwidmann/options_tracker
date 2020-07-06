defmodule OptionsTracker.Repo.Migrations.ChangeDatetimesToDate do
  use Ecto.Migration

  def change do
    alter table(:positions) do
      modify :opened_at, :date, from: :utc_datetime
      modify :closed_at, :date, from: :utc_datetime
      modify :expires_at, :date, from: :utc_datetime
    end
  end
end
