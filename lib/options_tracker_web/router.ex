defmodule OptionsTrackerWeb.Router do
  use OptionsTrackerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {OptionsTrackerWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :full_width do
    plug :put_root_layout, {OptionsTrackerWeb.LayoutView, :root_full}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", OptionsTrackerWeb do
    pipe_through :browser

    scope "/" do
      pipe_through :full_width
      live "/", PageLive, :index
    end

    live "/users", UserLive.Index, :index
    live "/users/new", UserLive.Index, :new
    live "/users/:id/edit", UserLive.Index, :edit

    live "/users/:id", UserLive.Show, :show
    live "/users/:id/show/edit", UserLive.Show, :edit

    live "/accounts", AccountLive.Index, :index
    live "/accounts/new", AccountLive.Index, :new
    live "/accounts/:id/edit", AccountLive.Index, :edit

    live "/accounts/:id", AccountLive.Show, :show
    live "/accounts/:id/show/edit", AccountLive.Show, :edit

    live "/positions", PositionLive.Index, :index
    live "/positions/new", PositionLive.Index, :new
    live "/positions/:id/edit", PositionLive.Index, :edit
    live "/positions/:id/close", PositionLive.Index, :close

    live "/positions/:id", PositionLive.Show, :show
    live "/positions/:id/show/edit", PositionLive.Show, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", OptionsTrackerWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: OptionsTrackerWeb.Telemetry
    end
  end
end
