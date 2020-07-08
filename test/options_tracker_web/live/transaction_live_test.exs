defmodule OptionsTrackerWeb.PositionLiveTest do
  use OptionsTrackerWeb.ConnCase

  import Phoenix.LiveViewTest

  alias OptionsTracker.Accounts

  @create_attrs %{
    basis: 120.5,
    closed_at: ~N[2010-04-17 14:00:00],
    direction: 42,
    exit_price: 120.5,
    exit_strategy: "some exit_strategy",
    expires_at: ~N[2010-04-17 14:00:00],
    fees: 120.5,
    notes: "some notes",
    opened_at: ~N[2010-04-17 14:00:00],
    premium: 120.5,
    profit_loss: 120.5,
    status: 42,
    stock: "some stock",
    strike: 120.5,
    type: 42
  }
  @update_attrs %{
    basis: 456.7,
    closed_at: ~N[2011-05-18 15:01:01],
    direction: 43,
    exit_price: 456.7,
    exit_strategy: "some updated exit_strategy",
    expires_at: ~N[2011-05-18 15:01:01],
    fees: 456.7,
    notes: "some updated notes",
    opened_at: ~N[2011-05-18 15:01:01],
    premium: 456.7,
    profit_loss: 456.7,
    status: 43,
    stock: "some updated stock",
    strike: 456.7,
    type: 43
  }
  @invalid_attrs %{
    basis: nil,
    closed_at: nil,
    direction: nil,
    exit_price: nil,
    exit_strategy: nil,
    expires_at: nil,
    fees: nil,
    notes: nil,
    opened_at: nil,
    premium: nil,
    profit_loss: nil,
    status: nil,
    stock: nil,
    strike: nil,
    type: nil
  }

  defp fixture(:position) do
    {:ok, position} = Accounts.create_position(%User{id: 123}, @create_attrs)
    position
  end

  defp create_position(_) do
    position = fixture(:position)
    %{position: position}
  end

  describe "Index" do
    setup [:create_position]

    test "lists all positions", %{conn: conn, position: position} do
      {:ok, _index_live, html} = live(conn, Routes.position_index_path(conn, :index))

      assert html =~ "Listing Positions"
      assert html =~ position.exit_strategy
    end

    test "saves new position", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.position_index_path(conn, :index))

      assert index_live |> element("a", "New Position") |> render_click() =~
               "New Position"

      assert_patch(index_live, Routes.position_index_path(conn, :new))

      assert index_live
             |> form("#position-form", position: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#position-form", position: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.position_index_path(conn, :index))

      assert html =~ "Position created successfully"
      assert html =~ "some exit_strategy"
    end

    test "updates position in listing", %{conn: conn, position: position} do
      {:ok, index_live, _html} = live(conn, Routes.position_index_path(conn, :index))

      assert index_live |> element("#position-#{position.id} a", "Edit") |> render_click() =~
               "Edit Position"

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

      assert index_live |> element("#position-#{position.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#position-#{position.id}")
    end
  end

  describe "Show" do
    setup [:create_position]

    test "displays position", %{conn: conn, position: position} do
      {:ok, _show_live, html} = live(conn, Routes.position_show_path(conn, :show, position))

      assert html =~ "Show Position"
      assert html =~ position.exit_strategy
    end

    test "updates position within modal", %{conn: conn, position: position} do
      {:ok, show_live, _html} = live(conn, Routes.position_show_path(conn, :show, position))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Position"

      assert_patch(show_live, Routes.position_show_path(conn, :edit, position))

      assert show_live
             |> form("#position-form", position: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#position-form", position: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.position_show_path(conn, :show, position))

      assert html =~ "Position updated successfully"
      assert html =~ "some updated exit_strategy"
    end
  end
end
