defmodule OptionsTracker.Repo.Migrations.Feedback do
  use Ecto.Migration

  def change do
    create table(:feedback) do
      add :rating, :integer, null: false
      add :text, :text
      add :path, :string
      add :read, :boolean
      add :response, :text

      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end
  end
end
