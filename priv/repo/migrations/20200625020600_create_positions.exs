defmodule OptionsTracker.Repo.Migrations.CreatePositions do
  use Ecto.Migration

  def change do
    create table(:positions) do
      add :stock, :string, null: false
      add :strike, :float, null: false
      add :short, :boolean, null: false
      add :spread, :boolean
      add :type, :integer, null: false
      add :opened_at, :utc_datetime, null: false
      add :premium, :float
      add :expires_at, :utc_datetime
      add :fees, :float
      add :spread_width, :float

      add :basis, :float
      add :closed_at, :utc_datetime
      add :profit_loss, :float
      add :status, :integer, null: false
      add :exit_price, :float

      add :notes, :text
      add :exit_strategy, :text

      add :account_id, references(:accounts, on_delete: :nothing)

      timestamps()
    end

    create index(:positions, [:account_id])
  end
end
