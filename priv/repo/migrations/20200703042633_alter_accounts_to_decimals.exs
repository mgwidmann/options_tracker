defmodule OptionsTracker.Repo.Migrations.AlterAccountsToDecimals do
  use Ecto.Migration

  def change do
    alter table(:accounts) do
      modify :exercise_fee, :decimal, from: :float
      modify :opt_close_fee, :decimal, from: :float
      modify :opt_open_fee, :decimal, from: :float
      modify :stock_close_fee, :decimal, from: :float
      modify :stock_open_fee, :decimal, from: :float
    end
  end
end
