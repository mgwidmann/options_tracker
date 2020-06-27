defmodule OptionsTracker.AccountsTest do
  use OptionsTracker.DataCase

  alias OptionsTracker.Accounts

  describe "accounts" do
    alias OptionsTracker.Accounts.Account

    @valid_attrs %{
      cash: "120.5",
      exercise_fee: 120.5,
      name: "some name",
      opt_close_fee: 120.5,
      opt_open_fee: 120.5,
      stock_close_fee: 120.5,
      stock_open_fee: 120.5,
      type: 0
    }
    @update_attrs %{
      cash: "456.7",
      exercise_fee: 456.7,
      name: "some updated name",
      opt_close_fee: 456.7,
      opt_open_fee: 456.7,
      stock_close_fee: 456.7,
      stock_open_fee: 456.7,
      type: 1
    }
    @invalid_attrs %{
      cash: nil,
      exercise_fee: nil,
      name: nil,
      opt_close_fee: nil,
      opt_open_fee: nil,
      stock_close_fee: nil,
      stock_open_fee: nil,
      type: nil
    }

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

    @valid_attrs %{
      short: true,
      count: 1,
      exit_strategy: "some exit_strategy",
      expires_at: ~N[2010-04-17 14:00:00],
      fees: 1.5,
      notes: "some notes",
      opened_at: ~N[2010-04-17 14:00:00],
      premium: 1.50,
      status: :open,
      stock: "XYZ",
      strike: 120.5,
      type: :call
    }
    @update_attrs %{
      closed_at: ~N[2011-05-18 15:01:01],
      short: true,
      exit_price: 1.7,
      exit_strategy: "some updated exit_strategy",
      fees: 2.50,
      notes: "some updated notes",
      status: :closed
    }
    @invalid_attrs %{
      closed_at: nil,
      fees: nil,
      notes: nil,
      opened_at: nil,
      premium: nil,
      status: nil
    }

    def position_fixture(attrs \\ %{}) do
      account = account_fixture()

      {:ok, position} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Enum.into(%{account_id: account.id})
        |> Accounts.create_position()

      position
    end

    @valid_stock_attrs %{
      type: :stock,
      count: 100,
      stock: "XYZ",
      short: false,
      premium: nil,
      strike: 100.00,
      expires_at: nil,
      basis: 100.00,
      closed_at: nil,
      fees: 0
    }
    def stock_position_fixture(attrs \\ %{}) do
      attrs
      |> Enum.into(@valid_stock_attrs)
      |> Enum.into(@valid_attrs)
      |> position_fixture()
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
      account = account_fixture()

      assert {:ok, %Position{} = position} =
               Accounts.create_position(@valid_attrs |> Enum.into(%{account_id: account.id}))

      # Not valid on non-stocks
      assert position.basis == nil
      assert position.closed_at == nil
      assert position.short == true
      assert position.exit_price == nil
      assert position.exit_strategy == "some exit_strategy"
      assert position.expires_at == ~U[2010-04-17 14:00:00Z]
      assert position.fees == 1.5
      assert position.notes == "some notes"
      assert position.opened_at == ~U[2010-04-17 14:00:00Z]
      assert position.premium == 1.5
      assert position.profit_loss == nil
      assert position.status == :open
      assert position.stock == "XYZ"
      assert position.strike == 120.5
      assert position.type == :call
    end

    test "create_position/1 with valid data creates a stock position" do
      account = account_fixture()
      attrs = @valid_stock_attrs |> Enum.into(%{account_id: account.id})

      assert {:ok, %Position{} = position} =
               Accounts.create_position(attrs |> Enum.into(@valid_attrs))

      assert position.basis == 100.00
      assert position.closed_at == nil
      assert position.short == false
      assert position.exit_price == nil
      assert position.exit_strategy == "some exit_strategy"
      assert position.expires_at == nil
      assert position.fees == 0
      assert position.notes == "some notes"
      assert position.opened_at == ~U[2010-04-17 14:00:00Z]
      assert position.premium == nil
      assert position.profit_loss == nil
      assert position.status == :open
      assert position.stock == "XYZ"
      assert position.strike == 100.00
      assert position.type == :stock
    end

    test "create_position/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_position(@invalid_attrs)
    end

    test "update_position/2 with valid data updates the position" do
      position = position_fixture()
      assert {:ok, %Position{} = position} = Accounts.update_position(position, @update_attrs)
      # Basis are always nil on options and cannot be updated
      assert position.basis == nil
      assert position.closed_at == ~U[2011-05-18 15:01:01Z]
      assert position.short == true
      assert position.exit_price == 1.7
      assert position.exit_strategy == "some updated exit_strategy"
      # Unchanged
      assert position.expires_at == ~U[2010-04-17 14:00:00Z]
      assert position.fees == 2.5
      assert position.notes == "some updated notes"
      # Unchanged
      assert position.opened_at == ~U[2010-04-17 14:00:00Z]
      assert position.premium == 1.5
      assert position.profit_loss == -20
      assert position.status == :closed
      assert position.stock == "XYZ"
      assert position.strike == 120.5
      assert position.type == :call
    end

    test "update_position/2 with valid data updates the stock position" do
      position = stock_position_fixture()

      assert {:ok, %Position{} = position} =
               Accounts.update_position(position, %{exit_price: 150} |> Enum.into(@update_attrs))

      assert position.basis == 100.00
      assert position.closed_at == ~U[2011-05-18 15:01:01Z]
      assert position.short == false
      assert position.exit_price == 150.0
      assert position.exit_strategy == "some updated exit_strategy"
      # doesn't exist on stocks
      assert position.expires_at == nil
      assert position.fees == 2.5
      assert position.notes == "some updated notes"
      assert position.opened_at == ~U[2010-04-17 14:00:00Z]
      # doesn't exist on stocks
      assert position.premium == nil
      assert position.profit_loss == 5000
      assert position.status == :closed
      assert position.stock == "XYZ"
      assert position.strike == 100.0
      assert position.type == :stock
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

    test "create_position/1 with call on same long stock lowers basis on close" do
      account = account_fixture()
      stock = stock_position_fixture(%{account_id: account.id})

      position =
        position_fixture(%{stock: stock.stock, type: :call, premium: 1.50, account_id: account.id})

      assert {:ok, %Position{} = position} =
               Accounts.update_position(position, %{
                 exit_price: 0.05,
                 closed_at: ~U[2011-05-18 15:01:01Z],
                 status: :closed
               })

      old_basis = stock.basis
      stock = Accounts.get_position!(stock.id)
      assert old_basis != stock.basis
      assert stock.basis == stock.strike - 1.45
    end

    test "create_position/1 with put on same short stock raises basis on close" do
      account = account_fixture()
      stock = stock_position_fixture(%{short: true, account_id: account.id})

      position =
        position_fixture(%{stock: stock.stock, type: :put, premium: 1.50, account_id: account.id})

      assert {:ok, %Position{} = position} =
               Accounts.update_position(position, %{
                 exit_price: 0.05,
                 closed_at: ~U[2011-05-18 15:01:01Z],
                 status: :closed
               })

      old_basis = stock.basis
      stock = Accounts.get_position!(stock.id)
      assert old_basis != stock.basis
      assert stock.basis == stock.strike + 1.45
    end
  end
end
