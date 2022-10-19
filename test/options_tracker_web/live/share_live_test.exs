defmodule OptionsTrackerWeb.ShareLiveTest do
  use OptionsTrackerWeb.ConnCase

  import Phoenix.LiveViewTest

  alias OptionsTracker.Users

  # @create_attrs %{hash: "some hash"}
  # @update_attrs %{hash: "some updated hash"}
  # @invalid_attrs %{hash: nil}

  defp fixture(:share) do
    user = user_fixture()
    {:ok, share} = Users.create_share(user, [position_fixture().id])
    share
  end

  defp create_share(_) do
    share = fixture(:share)
    %{share: share}
  end

  describe "Show" do
    setup [:create_share]

    test "displays share", %{conn: conn, share: share} do
      path = Routes.share_show_path(conn, :show, %{id: share.hash})
      {:ok, _show_live, html} = live(conn, path)

      assert html =~ "$1.50cr"
    end
  end
end
