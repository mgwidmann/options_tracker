defmodule OptionsTracker.AccountsTest do
  use OptionsTracker.DataCase

  alias OptionsTracker.Accounts
  alias OptionsTracker.Users.User

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
      broker_name: "a broker name",
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

    def user_fixture() do
      {:ok, user} =
        OptionsTracker.Users.register_user(%{
          email: "user#{Enum.random(1..1_000_000_000)}@email.com",
          password: "longpassword"
        })

      user
    end

    def account_fixture(attrs \\ %{}) do
      {:ok, account} =
        attrs
        |> Enum.into(@valid_attrs |> Map.put(:user_id, user_fixture().id))
        |> Accounts.create_account()

      account
    end

    test "list_accounts/0 returns all accounts" do
      account = account_fixture()
      assert Accounts.list_accounts(account.user_id) == [account]
    end

    test "get_account!/1 returns the account with given id" do
      account = account_fixture()
      assert Accounts.get_account!(account.id) == account
    end

    test "create_account/1 with valid data creates a account" do
      user = user_fixture()
      assert {:ok, %Account{} = account} = Accounts.create_account(@valid_attrs |> Map.put(:user_id, user.id))
      assert account.cash == Decimal.new("120.5")
      assert Decimal.eq?(account.exercise_fee, Decimal.from_float(120.5))
      assert account.name == "some name"
      assert Decimal.eq?(account.opt_close_fee, Decimal.from_float(120.5))
      assert Decimal.eq?(account.opt_open_fee, Decimal.from_float(120.5))
      assert Decimal.eq?(account.stock_close_fee, Decimal.from_float(120.5))
      assert Decimal.eq?(account.stock_open_fee, Decimal.from_float(120.5))
      assert account.type == :tasty_works
      assert account.user_id == user.id
    end

    test "create_account/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_account(@invalid_attrs)
    end

    test "update_account/2 with valid data updates the account" do
      account = account_fixture()
      assert {:ok, %Account{} = account} = Accounts.update_account(account, @update_attrs)
      assert Decimal.eq?(account.cash, Decimal.from_float(456.7))
      assert Decimal.eq?(account.exercise_fee, Decimal.from_float(456.7))
      assert account.name == "some updated name"
      assert Decimal.eq?(account.opt_close_fee, Decimal.from_float(456.7))
      assert Decimal.eq?(account.opt_open_fee, Decimal.from_float(456.7))
      assert Decimal.eq?(account.stock_close_fee, Decimal.from_float(456.7))
      assert Decimal.eq?(account.stock_open_fee, Decimal.from_float(456.7))
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
    @update_attrs %{
      closed_at: ~D[2011-05-18],
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

      attrs =
        attrs
        |> Enum.into(@valid_attrs)
        |> Enum.into(%{account_id: account.id})

      {:ok, position} = Accounts.create_position(attrs, %User{id: account.user_id})

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

    ####### BASIC CRUD ##########

    test "list_positions/1 returns all positions for an account" do
      account = account_fixture()
      position = position_fixture(%{account_id: account.id})
      assert Accounts.list_positions(account.id) == [position]
    end

    test "get_position!/1 returns the position with given id" do
      position = position_fixture()
      assert Accounts.get_position!(position.id) == position
    end

    test "create_position/1 with valid data creates a position" do
      account = account_fixture()

      assert {:ok, %Position{} = position} =
               Accounts.create_position(
                 @valid_attrs |> Enum.into(%{account_id: account.id}),
                 %User{id: account.user_id}
               )

      # Not valid on non-stocks
      assert position.basis == nil
      assert position.closed_at == nil
      assert position.short == true
      assert position.exit_price == nil
      assert position.exit_strategy == "some exit_strategy"
      assert position.expires_at == ~D[2010-04-17]
      assert position.fees == Decimal.from_float(1.5)
      assert position.notes == "some notes"
      assert position.opened_at == ~D[2010-04-17]
      assert position.premium == Decimal.from_float(1.5)
      assert position.profit_loss == nil
      assert position.status == :open
      assert position.stock == "XYZ"
      assert position.strike == Decimal.from_float(120.5)
      assert position.type == :call
    end

    test "create_position/1 with valid data creates a stock position" do
      account = account_fixture()
      attrs = @valid_stock_attrs |> Enum.into(%{account_id: account.id})

      assert {:ok, %Position{} = position} =
               Accounts.create_position(attrs |> Enum.into(@valid_attrs), %User{
                 id: account.user_id
               })

      assert position.basis == Decimal.from_float(100.00)
      assert position.closed_at == nil
      assert position.short == false
      assert position.exit_price == nil
      assert position.exit_strategy == "some exit_strategy"
      assert position.expires_at == nil
      assert position.fees == Decimal.from_float(0.0)
      assert position.notes == "some notes"
      assert position.opened_at == ~D[2010-04-17]
      assert position.premium == nil
      assert position.profit_loss == nil
      assert position.status == :open
      assert position.stock == "XYZ"
      assert position.strike == Decimal.from_float(100.00)
      assert position.type == :stock
    end

    test "create_position/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_position(@invalid_attrs, %User{id: 123})
    end

    test "update_position/3 with valid data updates the position" do
      account = account_fixture()
      position = position_fixture()

      assert {:ok, %Position{} = position} =
               Accounts.update_position(position, @update_attrs, %User{id: account.user_id})

      # Basis are always nil on options and cannot be updated
      assert position.basis == nil
      assert position.closed_at == ~D[2011-05-18]
      assert position.short == true
      assert position.exit_price == Decimal.from_float(1.7)
      assert position.exit_strategy == "some updated exit_strategy"
      # Unchanged
      assert position.expires_at == ~D[2010-04-17]
      assert position.fees == Decimal.from_float(2.5)
      assert position.notes == "some updated notes"
      # Unchanged
      assert position.opened_at == ~D[2010-04-17]
      assert position.premium == Decimal.from_float(1.5)
      assert position.profit_loss == Decimal.from_float(-20.0)
      assert position.status == :closed
      assert position.stock == "XYZ"
      assert position.strike == Decimal.from_float(120.5)
      assert position.type == :call
    end

    test "update_position/3 with valid data updates the stock position" do
      account = account_fixture()
      position = stock_position_fixture()

      assert {:ok, %Position{} = position} =
               Accounts.update_position(
                 position,
                 %{exit_price: 150} |> Enum.into(@update_attrs),
                 %User{id: account.user_id}
               )

      assert position.basis == Decimal.from_float(100.00)
      assert position.closed_at == ~D[2011-05-18]
      assert position.short == true
      assert position.exit_price == Decimal.new(150)
      assert position.exit_strategy == "some updated exit_strategy"
      # doesn't exist on stocks
      assert position.expires_at == nil
      assert position.fees == Decimal.from_float(2.5)
      assert position.notes == "some updated notes"
      assert position.opened_at == ~D[2010-04-17]
      # doesn't exist on stocks
      assert position.premium == nil
      assert Decimal.eq?(position.profit_loss, Decimal.from_float(-5000.0))
      assert position.status == :closed
      assert position.stock == "XYZ"
      assert position.strike == Decimal.from_float(100.0)
      assert position.type == :stock
    end

    test "update_position/3 with invalid data returns error changeset" do
      account = account_fixture()
      position = position_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Accounts.update_position(position, @invalid_attrs, %User{id: account.user_id})

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

    ############ UPDATING BASIS ##########

    test "update_position/3 with call on same long stock lowers basis on close" do
      account = account_fixture()
      stock = stock_position_fixture(%{account_id: account.id})

      position =
        position_fixture(%{stock: stock.stock, type: :call, premium: 1.50, account_id: account.id})

      assert {:ok, %Position{} = position} =
               Accounts.update_position(
                 position,
                 %{
                   exit_price: Decimal.from_float(0.05),
                   closed_at: ~D[2011-05-18],
                   status: :closed
                 },
                 %User{id: account.user_id}
               )

      old_basis = stock.basis
      stock = Accounts.get_position!(stock.id)
      assert old_basis != stock.basis
      assert Decimal.eq?(Decimal.round(stock.basis, 2), Decimal.sub(stock.strike, Decimal.from_float(1.45)))
    end

    test "update_position/3 with put on same short stock raises basis on close" do
      account = account_fixture()
      stock = stock_position_fixture(%{short: true, account_id: account.id})

      position =
        position_fixture(%{stock: stock.stock, type: :put, premium: 1.50, account_id: account.id})

      assert {:ok, %Position{} = position} =
               Accounts.update_position(
                 position,
                 %{
                   exit_price: Decimal.from_float(0.05),
                   closed_at: ~D[2011-05-18],
                   status: :closed
                 },
                 %User{id: account.user_id}
               )

      old_basis = stock.basis
      stock = Accounts.get_position!(stock.id)
      assert old_basis != stock.basis
      assert Decimal.eq?(Decimal.round(stock.basis, 2), Decimal.add(stock.strike, Decimal.from_float(1.45)))
    end

    test "update_position/3 with calls on multiple long stock lowers basis on close" do
      account = account_fixture()
      # 2 purchases totaling 500 shares
      stock = stock_position_fixture(%{account_id: account.id, count: 100})
      other_stock = stock_position_fixture(%{account_id: account.id, count: 400})

      position =
        position_fixture(%{
          stock: stock.stock,
          count: 5,
          type: :call,
          premium: Decimal.from_float(1.50),
          account_id: account.id
        })

      assert {:ok, %Position{} = position} =
               Accounts.update_position(
                 position,
                 %{
                   exit_price: Decimal.from_float(0.05),
                   closed_at: ~D[2011-05-18],
                   status: :closed
                 },
                 %User{id: account.user_id}
               )

      old_basis = stock.basis
      stock = Accounts.get_position!(stock.id)
      assert old_basis != stock.basis
      assert stock.basis == Decimal.sub(stock.strike, Decimal.from_float(1.45))

      old_basis = other_stock.basis
      stock = Accounts.get_position!(other_stock.id)
      assert old_basis != stock.basis
      assert Decimal.eq?(Decimal.round(stock.basis, 2), Decimal.sub(other_stock.strike, Decimal.from_float(1.45)))
    end

    test "update_position/3 with puts on multiple short stock raises basis on close" do
      account = account_fixture()
      # 2 purchases totaling 500 shares
      stock = stock_position_fixture(%{short: true, account_id: account.id, count: 100})
      other_stock = stock_position_fixture(%{short: true, account_id: account.id, count: 400})

      position =
        position_fixture(%{
          stock: stock.stock,
          count: 5,
          type: :put,
          premium: 1.50,
          account_id: account.id
        })

      assert {:ok, %Position{} = position} =
               Accounts.update_position(
                 position,
                 %{
                   exit_price: Decimal.from_float(0.05),
                   closed_at: ~D[2011-05-18],
                   status: :closed
                 },
                 %User{id: account.user_id}
               )

      # 100 shares are updated
      old_basis = stock.basis
      stock = Accounts.get_position!(stock.id)
      assert old_basis != stock.basis
      assert Decimal.eq?(Decimal.round(stock.basis, 2), Decimal.add(stock.strike, Decimal.from_float(1.45)))

      # 400 other shares are updated
      old_basis = other_stock.basis
      stock = Accounts.get_position!(other_stock.id)
      assert old_basis != stock.basis
      assert Decimal.eq?(Decimal.round(stock.basis, 2), Decimal.add(other_stock.strike, Decimal.from_float(1.45)))
    end

    test "update_position/3 with calls on more long stock than available lowers basis on close" do
      account = account_fixture()
      # 600 shares selling 3 contracts
      stock = stock_position_fixture(%{account_id: account.id, count: 600})
      # untouched
      other_stock =
        stock_position_fixture(%{
          account_id: account.id,
          count: 600,
          opened_at: ~D[2010-04-18]
        })

      position =
        position_fixture(%{
          stock: stock.stock,
          count: 3,
          type: :call,
          premium: Decimal.from_float(1.50),
          account_id: account.id
        })

      assert {:ok, %Position{} = position} =
               Accounts.update_position(
                 position,
                 %{
                   exit_price: Decimal.from_float(0.05),
                   closed_at: ~D[2011-05-18],
                   status: :closed
                 },
                 %User{id: account.user_id}
               )

      # 600 shares are updated
      old_basis = stock.basis
      stock = Accounts.get_position!(stock.id)
      assert old_basis != stock.basis

      assert Decimal.eq?(Decimal.round(stock.basis, 2), Decimal.sub(stock.strike, Decimal.from_float(0.72)))

      # 600 other shares are not updated
      stock = Accounts.get_position!(other_stock.id)
      assert old_basis == stock.basis
    end

    test "update_position/3 with puts on more short stock than available raises basis on close" do
      account = account_fixture()
      # 600 shares selling 3 contracts
      stock = stock_position_fixture(%{short: true, account_id: account.id, count: 600})
      # untouched
      other_stock =
        stock_position_fixture(%{
          short: true,
          account_id: account.id,
          count: 600,
          opened_at: ~D[2010-04-18]
        })

      position =
        position_fixture(%{
          stock: stock.stock,
          count: 3,
          type: :put,
          premium: Decimal.from_float(1.50),
          account_id: account.id
        })

      assert {:ok, %Position{} = position} =
               Accounts.update_position(
                 position,
                 %{
                   exit_price: Decimal.from_float(0.05),
                   closed_at: ~D[2011-05-18],
                   status: :closed
                 },
                 %User{id: account.user_id}
               )

      # 600 shares are updated
      old_basis = stock.basis
      stock = Accounts.get_position!(stock.id)
      assert old_basis != stock.basis

      # Basis is raised by half of 1.45 (profit), rounded to 73 due to rounding of stock.basis below
      assert Decimal.eq?(Decimal.round(stock.basis, 2), Decimal.add(stock.strike, Decimal.from_float(0.73)))

      # 600 other shares are not updated
      stock = Accounts.get_position!(other_stock.id)
      assert old_basis == stock.basis
    end

    test "update_position/3 with call on uneven amount of long stock lowers basis average on close" do
      account = account_fixture()
      # 110 shares, lowers basis less because the 10 additional shares
      stock = stock_position_fixture(%{account_id: account.id, count: 110})

      position =
        position_fixture(%{
          stock: stock.stock,
          count: 1,
          type: :call,
          premium: Decimal.from_float(1.50),
          account_id: account.id
        })

      assert {:ok, %Position{} = position} =
               Accounts.update_position(
                 position,
                 %{
                   exit_price: Decimal.from_float(0.05),
                   closed_at: ~D[2011-05-18],
                   status: :closed
                 },
                 %User{id: account.user_id}
               )

      old_basis = stock.basis
      stock = Accounts.get_position!(stock.id)
      assert old_basis != stock.basis
      # 1.45 spread across 10 additional shares
      assert Decimal.eq?(Decimal.round(stock.basis, 2), Decimal.sub(stock.strike, Decimal.from_float(1.32)))
    end

    test "update_position/3 with put on uneven amount of short stock raises basis average on close" do
      account = account_fixture()
      # 110 shares, raises basis less because of the 10 additional shares
      stock = stock_position_fixture(%{short: true, account_id: account.id, count: 110})

      position =
        position_fixture(%{
          stock: stock.stock,
          count: 1,
          type: :put,
          premium: Decimal.from_float(1.50),
          account_id: account.id
        })

      assert {:ok, %Position{} = position} =
               Accounts.update_position(
                 position,
                 %{
                   exit_price: Decimal.from_float(0.05),
                   closed_at: ~D[2011-05-18],
                   status: :closed
                 },
                 %User{id: account.user_id}
               )

      # 100 shares are updated
      old_basis = stock.basis
      stock = Accounts.get_position!(stock.id)
      assert old_basis != stock.basis
      # 1.45 spread across 10 additional shares
      assert Decimal.eq?(Decimal.round(stock.basis, 2), Decimal.add(stock.strike, Decimal.from_float(1.32)))
    end

    test "update_position/3 with call on less than available long stock lowers basis average on close" do
      account = account_fixture()
      # 1000 shares but only 5 contracts leaving 500 shares remaining
      stock = stock_position_fixture(%{account_id: account.id, count: 1000})

      position =
        position_fixture(%{
          stock: stock.stock,
          count: 5,
          type: :call,
          premium: Decimal.from_float(1.50),
          account_id: account.id
        })

      assert {:ok, %Position{} = position} =
               Accounts.update_position(
                 position,
                 %{
                   exit_price: Decimal.from_float(0.05),
                   closed_at: ~D[2011-05-18],
                   status: :closed
                 },
                 %User{id: account.user_id}
               )

      old_basis = stock.basis
      stock = Accounts.get_position!(stock.id)
      assert old_basis != stock.basis
      # 1.45 spread across 500 additional shares
      assert Decimal.eq?(Decimal.round(stock.basis, 2), Decimal.sub(stock.strike, Decimal.from_float(0.72)))
    end

    test "update_position/3 with put on less than available short stock raises basis average on close" do
      account = account_fixture()
      # 1000 shares but only 5 contracts
      stock = stock_position_fixture(%{short: true, account_id: account.id, count: 1000})

      position =
        position_fixture(%{
          stock: stock.stock,
          count: 5,
          type: :put,
          premium: Decimal.from_float(1.50),
          account_id: account.id
        })

      assert {:ok, %Position{} = position} =
               Accounts.update_position(
                 position,
                 %{
                   exit_price: Decimal.from_float(0.05),
                   closed_at: ~D[2011-05-18],
                   status: :closed
                 },
                 %User{id: account.user_id}
               )

      # 100 shares are updated
      old_basis = stock.basis
      stock = Accounts.get_position!(stock.id)
      assert old_basis != stock.basis
      # 1.45 spread across 500 additional shares, raises by 0.73 due to rounding of stock.basis
      assert Decimal.eq?(Decimal.round(stock.basis, 2), Decimal.add(stock.strike, Decimal.from_float(0.73)))
    end

    ################# HANDLING EXERCISE ####################

    test "update_position/3 with call on same long stock exercised" do
      account = account_fixture()
      stock = stock_position_fixture(%{account_id: account.id})

      position =
        position_fixture(%{
          stock: stock.stock,
          strike: Decimal.from_float(101.00),
          type: :call,
          premium: Decimal.from_float(1.50),
          account_id: account.id
        })

      assert {:ok, %Position{} = position} =
               Accounts.update_position(
                 position,
                 %{
                   exit_price: Decimal.from_float(0.00),
                   closed_at: ~D[2011-05-18],
                   status: :exercised
                 },
                 %User{id: account.user_id}
               )

      # Profit from premium
      assert position.profit_loss == Decimal.from_float(150.00)

      stock = Accounts.get_position!(stock.id)
      assert stock.status == :closed
      assert stock.profit_loss == Decimal.from_float(100.00)
    end

    test "update_position/3 with put on same short stock exercised" do
      account = account_fixture()
      stock = stock_position_fixture(%{short: true, account_id: account.id})

      position =
        position_fixture(%{
          stock: stock.stock,
          strike: Decimal.from_float(99.00),
          type: :put,
          premium: Decimal.from_float(1.50),
          account_id: account.id
        })

      assert {:ok, %Position{} = position} =
               Accounts.update_position(
                 position,
                 %{
                   exit_price: Decimal.from_float(0.00),
                   closed_at: ~D[2011-05-18],
                   status: :exercised
                 },
                 %User{id: account.user_id}
               )

      # Profit from premium
      assert position.profit_loss == Decimal.from_float(150.00)

      old_basis = stock.basis
      stock = Accounts.get_position!(stock.id)
      assert old_basis == stock.basis
      assert stock.profit_loss == Decimal.from_float(100.00)
    end

    test "update_position/3 with calls on more long stock than available exercises" do
      account = account_fixture()
      # 600 shares selling 3 contracts
      stock = stock_position_fixture(%{account_id: account.id, count: 600})
      # untouched
      other_stock =
        stock_position_fixture(%{
          account_id: account.id,
          count: 600,
          opened_at: ~D[2010-04-18]
        })

      position =
        position_fixture(%{
          stock: stock.stock,
          strike: Decimal.from_float(101.00),
          count: 3,
          type: :call,
          premium: Decimal.from_float(1.50),
          account_id: account.id
        })

      assert {:ok, %Position{} = position} =
               Accounts.update_position(
                 position,
                 %{
                   exit_price: Decimal.from_float(0.00),
                   closed_at: ~D[2011-05-18],
                   status: :exercised
                 },
                 %User{id: account.user_id}
               )

      # 600 shares are updated
      stock = Accounts.get_position!(stock.id)
      assert stock.status == :open
      # Count lowered
      assert stock.count == 300

      new_position =
        Accounts.list_positions(account.id) |> Enum.sort_by(fn p -> p.id end) |> List.last()

      assert new_position.status == :closed
      assert new_position.count == 300
      assert new_position.profit_loss == Decimal.from_float(300.00)

      # 600 other shares are not updated
      stock = Accounts.get_position!(other_stock.id)
      assert stock.status == :open
      assert stock.count == 600
    end

    test "update_position/3 with puts on more short stock than available exercises" do
      account = account_fixture()
      # 600 shares selling 3 contracts
      stock = stock_position_fixture(%{short: true, account_id: account.id, count: 600})
      # untouched
      other_stock =
        stock_position_fixture(%{
          short: true,
          account_id: account.id,
          count: 600,
          opened_at: ~D[2010-04-18]
        })

      position =
        position_fixture(%{
          stock: stock.stock,
          strike: Decimal.from_float(99.00),
          count: 3,
          type: :put,
          premium: Decimal.from_float(1.50),
          account_id: account.id
        })

      assert {:ok, %Position{} = position} =
               Accounts.update_position(
                 position,
                 %{
                   exit_price: Decimal.from_float(0.00),
                   closed_at: ~D[2011-05-18],
                   status: :exercised
                 },
                 %User{id: account.user_id}
               )

      # 600 shares are updated
      stock = Accounts.get_position!(stock.id)
      assert stock.status == :open
      # Count lowered
      assert stock.count == 300

      new_position =
        Accounts.list_positions(account.id) |> Enum.sort_by(fn p -> p.id end) |> List.last()

      assert new_position.status == :closed
      assert new_position.count == 300
      assert new_position.profit_loss == Decimal.from_float(300.00)

      # 600 other shares are not updated
      stock = Accounts.get_position!(other_stock.id)
      assert stock.status == :open
      assert stock.count == 600
    end

    test "update_position/3 with calls on multiple long stock exercised" do
      account = account_fixture()
      # 2 purchases totaling 500 shares
      stock = stock_position_fixture(%{account_id: account.id, count: 100})
      other_stock = stock_position_fixture(%{account_id: account.id, count: 400})

      position =
        position_fixture(%{
          stock: stock.stock,
          strike: Decimal.from_float(101.00),
          count: 5,
          type: :call,
          premium: Decimal.from_float(1.50),
          account_id: account.id
        })

      assert {:ok, %Position{} = position} =
               Accounts.update_position(
                 position,
                 %{
                   exit_price: Decimal.from_float(0.00),
                   closed_at: ~D[2011-05-18],
                   status: :exercised
                 },
                 %User{id: account.user_id}
               )

      stock = Accounts.get_position!(stock.id)
      assert stock.status == :closed
      assert stock.profit_loss == Decimal.from_float(100.00)

      stock = Accounts.get_position!(other_stock.id)
      assert stock.status == :closed
      assert stock.profit_loss == Decimal.from_float(400.00)
    end

    test "update_position/3 with puts on multiple short stock exercised" do
      account = account_fixture()
      # 2 purchases totaling 500 shares
      stock = stock_position_fixture(%{short: true, account_id: account.id, count: 100})
      other_stock = stock_position_fixture(%{short: true, account_id: account.id, count: 400})

      position =
        position_fixture(%{
          stock: stock.stock,
          strike: Decimal.from_float(99.00),
          count: 5,
          type: :put,
          premium: Decimal.from_float(1.50),
          account_id: account.id
        })

      assert {:ok, %Position{} = position} =
               Accounts.update_position(
                 position,
                 %{
                   exit_price: Decimal.from_float(0.00),
                   closed_at: ~D[2011-05-18],
                   status: :exercised
                 },
                 %User{id: account.user_id}
               )

      stock = Accounts.get_position!(stock.id)
      assert stock.status == :closed
      assert stock.profit_loss == Decimal.from_float(100.00)

      stock = Accounts.get_position!(other_stock.id)
      assert stock.status == :closed
      assert stock.profit_loss == Decimal.from_float(400.00)
    end

    test "update_position/3 with call on uneven amount of long stock exercises" do
      account = account_fixture()
      # 110 shares, need to exercise only 100 of them
      stock = stock_position_fixture(%{account_id: account.id, count: 110})

      position =
        position_fixture(%{
          stock: stock.stock,
          count: 1,
          strike: Decimal.from_float(101.00),
          type: :call,
          premium: Decimal.from_float(1.50),
          account_id: account.id
        })

      assert {:ok, %Position{} = position} =
               Accounts.update_position(
                 position,
                 %{
                   exit_price: Decimal.from_float(0.00),
                   closed_at: ~D[2011-05-18],
                   status: :exercised
                 },
                 %User{id: account.user_id}
               )

      stock = Accounts.get_position!(stock.id)
      assert stock.count == 10
      assert stock.status == :open

      closed_stock =
        Accounts.list_positions(account.id) |> Enum.sort_by(fn p -> p.id end) |> List.last()

      assert closed_stock.status == :closed
      assert closed_stock.count == 100
      assert closed_stock.profit_loss == Decimal.from_float(100.00)
    end

    test "update_position/3 with put on uneven amount of short stock exercises" do
      account = account_fixture()
      # 110 shares, need to exercise only 100 of them
      stock = stock_position_fixture(%{short: true, account_id: account.id, count: 110})

      position =
        position_fixture(%{
          stock: stock.stock,
          count: 1,
          strike: Decimal.from_float(99.00),
          type: :put,
          premium: Decimal.from_float(1.50),
          account_id: account.id
        })

      assert {:ok, %Position{} = position} =
               Accounts.update_position(
                 position,
                 %{
                   exit_price: Decimal.from_float(0.00),
                   closed_at: ~D[2011-05-18],
                   status: :exercised
                 },
                 %User{id: account.user_id}
               )

      stock = Accounts.get_position!(stock.id)
      assert stock.count == 10
      assert stock.status == :open

      closed_stock =
        Accounts.list_positions(account.id) |> Enum.sort_by(fn p -> p.id end) |> List.last()

      assert closed_stock.status == :closed
      assert closed_stock.count == 100
      assert closed_stock.profit_loss == Decimal.from_float(100.00)
    end

    test "update_position/3 with call on less than available long stock exercises" do
      account = account_fixture()
      # 5 contracts need 500 shares but only 250
      stock = stock_position_fixture(%{account_id: account.id, count: 250})

      position =
        position_fixture(%{
          stock: stock.stock,
          count: 5,
          strike: Decimal.from_float(101.00),
          type: :call,
          premium: Decimal.from_float(1.50),
          account_id: account.id
        })

      assert {:ok, %Position{} = position} =
               Accounts.update_position(
                 position,
                 %{
                   exit_price: Decimal.from_float(0.00),
                   closed_at: ~D[2011-05-18],
                   status: :exercised
                 },
                 %User{id: account.user_id}
               )

      stock = Accounts.get_position!(stock.id)
      assert stock.count == 250
      assert stock.status == :closed
      assert stock.profit_loss == Decimal.from_float(250.00)

      open_shares =
        Accounts.list_positions(account.id) |> Enum.sort_by(fn p -> p.id end) |> List.last()

      assert open_shares.status == :open
      assert open_shares.count == 250
      assert open_shares.short == true
    end

    test "update_position/3 with put on less than available short stock exercises" do
      account = account_fixture()
      # 5 contracts need 500 shares but only 250
      stock = stock_position_fixture(%{short: true, account_id: account.id, count: 250})

      position =
        position_fixture(%{
          stock: stock.stock,
          count: 5,
          strike: Decimal.from_float(99.00),
          type: :put,
          premium: Decimal.from_float(1.50),
          account_id: account.id
        })

      assert {:ok, %Position{} = position} =
               Accounts.update_position(
                 position,
                 %{
                   exit_price: Decimal.from_float(0.00),
                   closed_at: ~D[2011-05-18],
                   status: :exercised
                 },
                 %User{id: account.user_id}
               )

      stock = Accounts.get_position!(stock.id)
      assert stock.count == 250
      assert stock.status == :closed
      assert stock.profit_loss == Decimal.from_float(250.00)

      open_shares =
        Accounts.list_positions(account.id) |> Enum.sort_by(fn p -> p.id end) |> List.last()

      assert open_shares.status == :open
      assert open_shares.count == 250
      assert open_shares.short == false
    end
  end
end
