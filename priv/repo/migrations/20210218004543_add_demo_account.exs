defmodule OptionsTracker.Repo.Migrations.AddDemoAccount do
  use Ecto.Migration
  alias OptionsTracker.Accounts
  alias OptionsTracker.Users

  def up do
    {:ok, user} = Users.register_user(%{
      email: OptionsTracker.Users.get_demo_user_email(),
      password: System.get_env("DEMO_PASSWORD", "testdemopassword")
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
