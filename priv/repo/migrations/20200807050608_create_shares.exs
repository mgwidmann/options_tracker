defmodule OptionsTracker.Repo.Migrations.CreateShares do
  use Ecto.Migration

  def change do
    create table(:shares) do
      add :hash, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:shares, [:hash])
    create index(:shares, [:user_id])

    create table(:positions_shares, primary_key: false) do
      add(:position_id, references(:positions, on_delete: :delete_all), primary_key: true)
      add(:share_id, references(:shares, on_delete: :delete_all), primary_key: true)
    end

    create(index(:positions_shares, [:position_id]))
    create(index(:positions_shares, [:share_id]))

    create(
      unique_index(:positions_shares, [:position_id, :share_id],
        name: :share_id_position_id_unique_index
      )
    )
  end
end
