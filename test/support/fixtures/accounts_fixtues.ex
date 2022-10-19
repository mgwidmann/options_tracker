defmodule OptionsTracker.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `OptionsTracker.Accounts` context.
  """
  alias OptionsTracker.Accounts
  alias OptionsTracker.Users.User
  import OptionsTracker.UsersFixtures

  @position_attrs %{
    short: true,
    count: 1,
    exit_strategy: "some exit_strategy",
    expires_at: ~D[2010-04-17],
    fees: 1.5,
    notes: "some notes",
    opened_at: ~D[2010-04-17],
    premium: 1.50,
    status: :open,
    stock: "XYZ",
    strike: 120.5,
    type: :call
  }
  def position_fixture(attrs \\ %{}) do
    account = account_fixture()

      attrs =
        attrs
        |> Enum.into(@position_attrs)
        |> Enum.into(%{account_id: account.id})

      {:ok, position} = Accounts.create_position(attrs, %User{id: account.user_id})

      position
  end

  @account_attrs %{
    cash: "120.5",
    exercise_fee: 120.5,
    name: "some name",
    opt_close_fee: 120.5,
    opt_open_fee: 120.5,
    stock_close_fee: 120.5,
    stock_open_fee: 120.5,
    type: 0
  }
  def account_fixture(attrs \\ %{}) do
    {:ok, account} =
      attrs
      |> Enum.into(@account_attrs |> Map.put(:user_id, user_fixture().id))
      |> Accounts.create_account()

    account
  end

end
