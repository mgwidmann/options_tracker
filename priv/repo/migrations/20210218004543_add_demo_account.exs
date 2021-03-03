defmodule OptionsTracker.Repo.Migrations.AddDemoAccount do
  use Ecto.Migration
  alias OptionsTracker.Accounts
  alias OptionsTracker.Users

  def up do
    {:ok, user} = Users.register_user(%{
      email: "demo@options-tracker.gigalixirapp.com",
      password: if(Mix.env == :test, do: "testdemopassword", else: System.get_env("DEMO_PASSWORD"))
    })
    Accounts.create_account(%{
      cash: "25000",
      exercise_fee: 5.00,
      name: "Demo",
      opt_close_fee: 0.14,
      opt_open_fee: 1.15,
      stock_close_fee: 0.0,
      stock_open_fee: 0.0,
      type: "tasty_works",
      user_id: user.id,
    })
  end

  def down do

  end
end
