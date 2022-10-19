defmodule OptionsTrackerWeb.HomeController do
  use OptionsTrackerWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html", layout: {OptionsTrackerWeb.LayoutView, :root_full})
  end
end
