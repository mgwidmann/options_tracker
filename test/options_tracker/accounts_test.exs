defmodule OptionsTracker.AccountsTest do
  use OptionsTracker.DataCase

  alias OptionsTracker.Accounts

  describe "accounts" do
    alias OptionsTracker.Accounts.Account

    @valid_attrs %{cash: "120.5", exercise_fee: 120.5, name: "some name", opt_close_fee: 120.5, opt_open_fee: 120.5, stock_close_fee: 120.5, stock_open_fee: 120.5, type: 0}
    @update_attrs %{cash: "456.7", exercise_fee: 456.7, name: "some updated name", opt_close_fee: 456.7, opt_open_fee: 456.7, stock_close_fee: 456.7, stock_open_fee: 456.7, type: 1}
    @invalid_attrs %{cash: nil, exercise_fee: nil, name: nil, opt_close_fee: nil, opt_open_fee: nil, stock_close_fee: nil, stock_open_fee: nil, type: nil}

    def account_fixture(attrs \\ %{}) do
      {:ok, account} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_account()

      account
    end

    test "list_accounts/0 returns all accounts" do
      account = account_fixture()
      assert Accounts.list_accounts() == [account]
    end

    test "get_account!/1 returns the account with given id" do
      account = account_fixture()
      assert Accounts.get_account!(account.id) == account
    end

    test "create_account/1 with valid data creates a account" do
      assert {:ok, %Account{} = account} = Accounts.create_account(@valid_attrs)
      assert account.cash == Decimal.new("120.5")
      assert account.exercise_fee == 120.5
      assert account.name == "some name"
      assert account.opt_close_fee == 120.5
      assert account.opt_open_fee == 120.5
      assert account.stock_close_fee == 120.5
      assert account.stock_open_fee == 120.5
      assert account.type == :tasty_works
    end

    test "create_account/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_account(@invalid_attrs)
    end

    test "update_account/2 with valid data updates the account" do
      account = account_fixture()
      assert {:ok, %Account{} = account} = Accounts.update_account(account, @update_attrs)
      assert account.cash == Decimal.new("456.7")
      assert account.exercise_fee == 456.7
      assert account.name == "some updated name"
      assert account.opt_close_fee == 456.7
      assert account.opt_open_fee == 456.7
      assert account.stock_close_fee == 456.7
      assert account.stock_open_fee == 456.7
      assert account.type == :robinhood
    end

    test "update_account/2 with invalid data returns error changeset" do
      account = account_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_account(account, @invalid_attrs)
      assert account == Accounts.get_account!(account.id)
    end

    test "delete_account/1 deletes the account" do
      account = account_fixture()
      assert {:ok, %Account{}} = Accounts.delete_account(account)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_account!(account.id) end
    end

    test "change_account/1 returns a account changeset" do
      account = account_fixture()
      assert %Ecto.Changeset{} = Accounts.change_account(account)
    end
  end
end
