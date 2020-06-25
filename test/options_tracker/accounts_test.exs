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

  describe "transactions" do
    alias OptionsTracker.Accounts.Transaction

    @valid_attrs %{basis: 120.5, closed_at: ~N[2010-04-17 14:00:00], direction: 42, exit_price: 120.5, exit_strategy: "some exit_strategy", expires_at: ~N[2010-04-17 14:00:00], fees: 120.5, notes: "some notes", opened_at: ~N[2010-04-17 14:00:00], premium: 120.5, profit_loss: 120.5, status: 42, stock: "some stock", strike: 120.5, type: 42}
    @update_attrs %{basis: 456.7, closed_at: ~N[2011-05-18 15:01:01], direction: 43, exit_price: 456.7, exit_strategy: "some updated exit_strategy", expires_at: ~N[2011-05-18 15:01:01], fees: 456.7, notes: "some updated notes", opened_at: ~N[2011-05-18 15:01:01], premium: 456.7, profit_loss: 456.7, status: 43, stock: "some updated stock", strike: 456.7, type: 43}
    @invalid_attrs %{basis: nil, closed_at: nil, direction: nil, exit_price: nil, exit_strategy: nil, expires_at: nil, fees: nil, notes: nil, opened_at: nil, premium: nil, profit_loss: nil, status: nil, stock: nil, strike: nil, type: nil}

    def transaction_fixture(attrs \\ %{}) do
      {:ok, transaction} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_transaction()

      transaction
    end

    test "list_transactions/0 returns all transactions" do
      transaction = transaction_fixture()
      assert Accounts.list_transactions() == [transaction]
    end

    test "get_transaction!/1 returns the transaction with given id" do
      transaction = transaction_fixture()
      assert Accounts.get_transaction!(transaction.id) == transaction
    end

    test "create_transaction/1 with valid data creates a transaction" do
      assert {:ok, %Transaction{} = transaction} = Accounts.create_transaction(@valid_attrs)
      assert transaction.basis == 120.5
      assert transaction.closed_at == ~N[2010-04-17 14:00:00]
      assert transaction.direction == 42
      assert transaction.exit_price == 120.5
      assert transaction.exit_strategy == "some exit_strategy"
      assert transaction.expires_at == ~N[2010-04-17 14:00:00]
      assert transaction.fees == 120.5
      assert transaction.notes == "some notes"
      assert transaction.opened_at == ~N[2010-04-17 14:00:00]
      assert transaction.premium == 120.5
      assert transaction.profit_loss == 120.5
      assert transaction.status == 42
      assert transaction.stock == "some stock"
      assert transaction.strike == 120.5
      assert transaction.type == 42
    end

    test "create_transaction/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_transaction(@invalid_attrs)
    end

    test "update_transaction/2 with valid data updates the transaction" do
      transaction = transaction_fixture()
      assert {:ok, %Transaction{} = transaction} = Accounts.update_transaction(transaction, @update_attrs)
      assert transaction.basis == 456.7
      assert transaction.closed_at == ~N[2011-05-18 15:01:01]
      assert transaction.direction == 43
      assert transaction.exit_price == 456.7
      assert transaction.exit_strategy == "some updated exit_strategy"
      assert transaction.expires_at == ~N[2011-05-18 15:01:01]
      assert transaction.fees == 456.7
      assert transaction.notes == "some updated notes"
      assert transaction.opened_at == ~N[2011-05-18 15:01:01]
      assert transaction.premium == 456.7
      assert transaction.profit_loss == 456.7
      assert transaction.status == 43
      assert transaction.stock == "some updated stock"
      assert transaction.strike == 456.7
      assert transaction.type == 43
    end

    test "update_transaction/2 with invalid data returns error changeset" do
      transaction = transaction_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_transaction(transaction, @invalid_attrs)
      assert transaction == Accounts.get_transaction!(transaction.id)
    end

    test "delete_transaction/1 deletes the transaction" do
      transaction = transaction_fixture()
      assert {:ok, %Transaction{}} = Accounts.delete_transaction(transaction)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_transaction!(transaction.id) end
    end

    test "change_transaction/1 returns a transaction changeset" do
      transaction = transaction_fixture()
      assert %Ecto.Changeset{} = Accounts.change_transaction(transaction)
    end
  end
end
