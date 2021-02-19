defmodule OptionsTracker.Repo.Migrations.AddPublicToAccounts do
  use Ecto.Migration

  def change do
    alter table(:accounts) do
      add :public, :boolean, default: false
    end
  end
end
