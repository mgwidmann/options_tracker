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

  describe "positions" do
    alias OptionsTracker.Accounts.Position

    @valid_attrs %{basis: 120.5, closed_at: ~N[2010-04-17 14:00:00], direction: 42, exit_price: 120.5, exit_strategy: "some exit_strategy", expires_at: ~N[2010-04-17 14:00:00], fees: 120.5, notes: "some notes", opened_at: ~N[2010-04-17 14:00:00], premium: 120.5, profit_loss: 120.5, status: 42, stock: "some stock", strike: 120.5, type: 42}
    @update_attrs %{basis: 456.7, closed_at: ~N[2011-05-18 15:01:01], direction: 43, exit_price: 456.7, exit_strategy: "some updated exit_strategy", expires_at: ~N[2011-05-18 15:01:01], fees: 456.7, notes: "some updated notes", opened_at: ~N[2011-05-18 15:01:01], premium: 456.7, profit_loss: 456.7, status: 43, stock: "some updated stock", strike: 456.7, type: 43}
    @invalid_attrs %{basis: nil, closed_at: nil, direction: nil, exit_price: nil, exit_strategy: nil, expires_at: nil, fees: nil, notes: nil, opened_at: nil, premium: nil, profit_loss: nil, status: nil, stock: nil, strike: nil, type: nil}

    def position_fixture(attrs \\ %{}) do
      {:ok, position} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_position()

      position
    end

    test "list_positions/0 returns all positions" do
      position = position_fixture()
      assert Accounts.list_positions() == [position]
    end

    test "get_position!/1 returns the position with given id" do
      position = position_fixture()
      assert Accounts.get_position!(position.id) == position
    end

    test "create_position/1 with valid data creates a position" do
      assert {:ok, %Position{} = position} = Accounts.create_position(@valid_attrs)
      assert position.basis == 120.5
      assert position.closed_at == ~N[2010-04-17 14:00:00]
      assert position.direction == 42
      assert position.exit_price == 120.5
      assert position.exit_strategy == "some exit_strategy"
      assert position.expires_at == ~N[2010-04-17 14:00:00]
      assert position.fees == 120.5
      assert position.notes == "some notes"
      assert position.opened_at == ~N[2010-04-17 14:00:00]
      assert position.premium == 120.5
      assert position.profit_loss == 120.5
      assert position.status == 42
      assert position.stock == "some stock"
      assert position.strike == 120.5
      assert position.type == 42
    end

    test "create_position/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_position(@invalid_attrs)
    end

    test "update_position/2 with valid data updates the position" do
      position = position_fixture()
      assert {:ok, %Position{} = position} = Accounts.update_position(position, @update_attrs)
      assert position.basis == 456.7
      assert position.closed_at == ~N[2011-05-18 15:01:01]
      assert position.direction == 43
      assert position.exit_price == 456.7
      assert position.exit_strategy == "some updated exit_strategy"
      assert position.expires_at == ~N[2011-05-18 15:01:01]
      assert position.fees == 456.7
      assert position.notes == "some updated notes"
      assert position.opened_at == ~N[2011-05-18 15:01:01]
      assert position.premium == 456.7
      assert position.profit_loss == 456.7
      assert position.status == 43
      assert position.stock == "some updated stock"
      assert position.strike == 456.7
      assert position.type == 43
    end

    test "update_position/2 with invalid data returns error changeset" do
      position = position_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_position(position, @invalid_attrs)
      assert position == Accounts.get_position!(position.id)
    end

    test "delete_position/1 deletes the position" do
      position = position_fixture()
      assert {:ok, %Position{}} = Accounts.delete_position(position)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_position!(position.id) end
    end

    test "change_position/1 returns a position changeset" do
      position = position_fixture()
      assert %Ecto.Changeset{} = Accounts.change_position(position)
    end
  end
end
