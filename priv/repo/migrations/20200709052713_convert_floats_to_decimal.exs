defmodule OptionsTracker.Repo.Migrations.ConvertFloatsToDecimal do
  use Ecto.Migration

  def change do
    alter table(:positions) do
      modify :strike, :decimal, from: :float
      modify :premium, :decimal, from: :float
      modify :fees, :decimal, from: :float
      modify :spread_width, :decimal, from: :float
      modify :basis, :decimal, from: :float
      modify :profit_loss, :decimal, from: :float
      modify :exit_price, :decimal, from: :float

      remove :spread, :boolean
    end
  end
end
