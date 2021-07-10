defmodule OptionsTracker.Repo.Migrations.CreateSentiment do
  use Ecto.Migration

  def change do
    create table(:sentiment) do
      add :campaign, :string
      add :answer, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:sentiment, [:user_id])
  end
end
