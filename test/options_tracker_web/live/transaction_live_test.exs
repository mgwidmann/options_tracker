defmodule OptionsTrackerWeb.TransactionLiveTest do
  use OptionsTrackerWeb.ConnCase

  import Phoenix.LiveViewTest

  alias OptionsTracker.Accounts

  @create_attrs %{basis: 120.5, closed_at: ~N[2010-04-17 14:00:00], direction: 42, exit_price: 120.5, exit_strategy: "some exit_strategy", expires_at: ~N[2010-04-17 14:00:00], fees: 120.5, notes: "some notes", opened_at: ~N[2010-04-17 14:00:00], premium: 120.5, profit_loss: 120.5, status: 42, stock: "some stock", strike: 120.5, type: 42}
  @update_attrs %{basis: 456.7, closed_at: ~N[2011-05-18 15:01:01], direction: 43, exit_price: 456.7, exit_strategy: "some updated exit_strategy", expires_at: ~N[2011-05-18 15:01:01], fees: 456.7, notes: "some updated notes", opened_at: ~N[2011-05-18 15:01:01], premium: 456.7, profit_loss: 456.7, status: 43, stock: "some updated stock", strike: 456.7, type: 43}
  @invalid_attrs %{basis: nil, closed_at: nil, direction: nil, exit_price: nil, exit_strategy: nil, expires_at: nil, fees: nil, notes: nil, opened_at: nil, premium: nil, profit_loss: nil, status: nil, stock: nil, strike: nil, type: nil}

  defp fixture(:transaction) do
    {:ok, transaction} = Accounts.create_transaction(@create_attrs)
    transaction
  end

  defp create_transaction(_) do
    transaction = fixture(:transaction)
    %{transaction: transaction}
  end

  describe "Index" do
    setup [:create_transaction]

    test "lists all transactions", %{conn: conn, transaction: transaction} do
      {:ok, _index_live, html} = live(conn, Routes.transaction_index_path(conn, :index))

      assert html =~ "Listing Transactions"
      assert html =~ transaction.exit_strategy
    end

    test "saves new transaction", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.transaction_index_path(conn, :index))

      assert index_live |> element("a", "New Transaction") |> render_click() =~
               "New Transaction"

      assert_patch(index_live, Routes.transaction_index_path(conn, :new))

      assert index_live
             |> form("#transaction-form", transaction: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#transaction-form", transaction: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.transaction_index_path(conn, :index))

      assert html =~ "Transaction created successfully"
      assert html =~ "some exit_strategy"
    end

    test "updates transaction in listing", %{conn: conn, transaction: transaction} do
      {:ok, index_live, _html} = live(conn, Routes.transaction_index_path(conn, :index))

      assert index_live |> element("#transaction-#{transaction.id} a", "Edit") |> render_click() =~
               "Edit Transaction"

      assert_patch(index_live, Routes.transaction_index_path(conn, :edit, transaction))

      assert index_live
             |> form("#transaction-form", transaction: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#transaction-form", transaction: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.transaction_index_path(conn, :index))

      assert html =~ "Transaction updated successfully"
      assert html =~ "some updated exit_strategy"
    end

    test "deletes transaction in listing", %{conn: conn, transaction: transaction} do
      {:ok, index_live, _html} = live(conn, Routes.transaction_index_path(conn, :index))

      assert index_live |> element("#transaction-#{transaction.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#transaction-#{transaction.id}")
    end
  end

  describe "Show" do
    setup [:create_transaction]

    test "displays transaction", %{conn: conn, transaction: transaction} do
      {:ok, _show_live, html} = live(conn, Routes.transaction_show_path(conn, :show, transaction))

      assert html =~ "Show Transaction"
      assert html =~ transaction.exit_strategy
    end

    test "updates transaction within modal", %{conn: conn, transaction: transaction} do
      {:ok, show_live, _html} = live(conn, Routes.transaction_show_path(conn, :show, transaction))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Transaction"

      assert_patch(show_live, Routes.transaction_show_path(conn, :edit, transaction))

      assert show_live
             |> form("#transaction-form", transaction: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#transaction-form", transaction: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.transaction_show_path(conn, :show, transaction))

      assert html =~ "Transaction updated successfully"
      assert html =~ "some updated exit_strategy"
    end
  end
end
