defmodule OptionsTrackerWeb.ErrorViewTest do
  use OptionsTrackerWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  @tag :pending
  test "renders 404.html", %{conn: conn} do
    assert render_to_string(OptionsTrackerWeb.ErrorView, "404.html", [conn: conn, status: :not_found]) =~ "Not Found"
  end

  @tag :pending
  test "renders 500.html", %{conn: conn} do
    assert render_to_string(OptionsTrackerWeb.ErrorView, "500.html", [conn: conn, status: :internal_error]) =~
             "Internal Server Error"
  end
end
