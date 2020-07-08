defmodule OptionsTracker.Repo.Migrations.AddPositionsAudit do
  use Ecto.Migration

  def change do
    create table(:positions_audit) do
      add :action, :integer
      add :before, :map

      add :user_id, references(:users, on_delete: :nothing)
      add :position_id, references(:positions, on_delete: :nothing)
      add :account_id, references(:accounts, on_delete: :nothing)

      timestamps()
    end
  end
end
