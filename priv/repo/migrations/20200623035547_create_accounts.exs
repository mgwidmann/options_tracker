defmodule OptionsTracker.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :name, :string
      add :broker_name, :string
      add :type, :integer
      add :opt_open_fee, :float
      add :opt_close_fee, :float
      add :stock_open_fee, :float
      add :stock_close_fee, :float
      add :exercise_fee, :float
      add :cash, :decimal
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:accounts, [:user_id])
  end
end
