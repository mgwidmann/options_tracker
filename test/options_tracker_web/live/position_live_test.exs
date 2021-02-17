defmodule OptionsTrackerWeb.PositionLiveTest do
  use OptionsTrackerWeb.ConnCase

  import Phoenix.LiveViewTest

  alias OptionsTracker.Accounts

  @valid_account_attrs %{
    cash: "120.5",
    exercise_fee: 120.5,
    name: "some name",
    opt_close_fee: 120.5,
    opt_open_fee: 120.5,
    stock_close_fee: 120.5,
    stock_open_fee: 120.5,
    type: 0
  }

  @create_attrs %{
    short: true,
    count: 1,
    expires_at: ~D[2010-04-17],
    fees: 120.5,
    opened_at: ~D[2010-04-17],
    premium: 120.5,
    stock: "some stock",
    strike: 120.5,
    type: :put
  }
  @update_attrs %{
    basis: 456.7,
    closed_at: ~D[2011-05-18],
    direction: 43,
    exit_price: 456.7,
    exit_strategy: "some updated exit_strategy",
    expires_at: ~D[2011-05-18],
    fees: 456.7,
    notes: "some updated notes",
    opened_at: ~D[2011-05-18],
    premium: 456.7,
    profit_loss: 456.7,
    status: 43,
    stock: "some updated stock",
    strike: 456.7,
    type: :call
  }
  @invalid_attrs %{
    expires_at: nil,
    fees: nil,
    opened_at: nil,
    premium: nil,
    stock: nil,
    strike: nil,
    type: nil
  }

  defp fixture(:position, user) do
    account = fixture(:account, user)
    {:ok, position} = Accounts.create_position(@create_attrs |> Map.put(:account_id, account.id), user)
    Map.put(position, :account, account)
  end

  defp fixture(:account, user) do
    {:ok, account} = Accounts.create_account(@valid_account_attrs |> Map.put(:user_id, user.id))

    account
  end

  defp create_position(%{user: user}) do
    position = fixture(:position, user)
    %{position: position}
  end

  describe "Index" do
    setup [:register_and_log_in_user, :create_position]

    test "lists all positions", %{conn: conn, position: position} do
      {:ok, _index_live, html} = live(conn, Routes.position_index_path(conn, :index))

      assert html =~ "Positions"
      assert html =~ position.stock
    end

    test "saves new position", %{conn: conn, position: position} do
      {:ok, index_live, _html} = live(conn, Routes.position_account_index_path(conn, :index, position.account_id))

      assert index_live |> element("a[href=\"/positions/accounts/#{position.account_id}/new\"]") |> render_click() =~
               "name=\"position[stock]\""

      assert_patch(index_live, Routes.position_index_path(conn, :new, position.account_id))

      assert index_live
             |> form("#position-form", position: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, view, html} =
        index_live
        |> form("#position-form", position: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn)

      assert html =~ "SOME STOCK"
    end

    @tag :pending
    test "updates position in listing", %{conn: conn, position: position} do
      {:ok, index_live, _html} = live(conn, Routes.position_index_path(conn, :index))

      assert index_live |> element("#position-#{position.id} a[href=\"/positions/#{position.id}/edit\"]") |> render_click() =~
               "name=\"position[stock]\""

      assert_patch(index_live, Routes.position_index_path(conn, :edit, position))

      assert index_live
             |> form("#position-form", position: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#position-form", position: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.position_index_path(conn, :index))

      assert html =~ "Position updated successfully"
      assert html =~ "some updated exit_strategy"
    end

    test "deletes position in listing", %{conn: conn, position: position} do
      {:ok, index_live, _html} = live(conn, Routes.position_index_path(conn, :index))

      assert index_live
             |> element("#position-#{position.id} a[href=\"/positions/#{position.id}/delete\"]")
             |> render_click() =~ "Are you sure"

      assert_patch(index_live, Routes.position_index_path(conn, :delete, position.id))

      {:ok, _, html} =
        index_live
        |> form("#delete-position", [])
        |> render_submit()
        |> follow_redirect(conn, Routes.position_index_path(conn, :index))

      refute html =~ "#position-#{position.id}"
    end
  end
end
