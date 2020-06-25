defmodule OptionsTracker.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :stock, :string
      add :strike, :float
      add :short, :boolean
      add :spread, :boolean
      add :type, :integer
      add :opened_at, :utc_datetime
      add :premium, :float
      add :expires_at, :utc_datetime
      add :fees, :float
      add :spread_width, :float

      add :basis, :float
      add :closed_at, :utc_datetime
      add :profit_loss, :float
      add :status, :integer
      add :exit_price, :float

      add :notes, :text
      add :exit_strategy, :text

      add :account_id, references(:accounts, on_delete: :nothing)

      timestamps()
    end

    create index(:transactions, [:account_id])
  end
end
