defmodule OptionsTracker.Repo.Migrations.AddAccumulatedProfitLoss do
  use Ecto.Migration

  def change do
    alter table(:positions) do
      add :accumulated_profit_loss, :decimal
      add :rolled_position_id, references(:positions, on_delete: :nothing)
    end
  end
end
