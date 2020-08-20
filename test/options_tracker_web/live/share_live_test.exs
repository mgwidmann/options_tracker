defmodule OptionsTrackerWeb.ShareLiveTest do
  use OptionsTrackerWeb.ConnCase

  import Phoenix.LiveViewTest

  alias OptionsTracker.Users

  @create_attrs %{hash: "some hash"}
  @update_attrs %{hash: "some updated hash"}
  @invalid_attrs %{hash: nil}

  defp fixture(:share) do
    {:ok, share} = Users.create_share(@create_attrs)
    share
  end

  defp create_share(_) do
    share = fixture(:share)
    %{share: share}
  end

  describe "Show" do
    setup [:create_share]

    test "displays share", %{conn: conn, share: share} do
      {:ok, _show_live, html} = live(conn, Routes.share_show_path(conn, :show, share))

      assert html =~ "Show Share"
      assert html =~ share.hash
    end
  end
end
