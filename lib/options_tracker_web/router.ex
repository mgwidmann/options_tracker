defmodule OptionsTrackerWeb.Router do
  use OptionsTrackerWeb, :router

  import OptionsTrackerWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {OptionsTrackerWeb.LayoutView, :root}
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :csrf do
    plug :protect_from_forgery
  end

  pipeline :full_width do
    plug :put_root_layout, {OptionsTrackerWeb.LayoutView, :root_full}
  end

  pipeline :admin do
    plug :restrict_admin
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", OptionsTrackerWeb do
    pipe_through [:browser, :csrf, :require_authenticated_user]

    # Users
    get "/users/settings", UserSettingsController, :edit
    put "/users/settings/update_password", UserSettingsController, :update_password
    put "/users/settings/update_email", UserSettingsController, :update_email
    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email

    # Accounts
    live "/accounts", AccountLive.Index, :index
    live "/accounts/new", AccountLive.Index, :new
    live "/accounts/:id/edit", AccountLive.Index, :edit
    live "/accounts/:id", AccountLive.Show, :show

    # Positions
    live "/positions", PositionLive.Index, :index
    live "/positions/accounts/:account_id", PositionLive.Index, :index, as: :position_account_index
    live "/positions/accounts/:account_id/new", PositionLive.Index, :new
    live "/positions/:id/edit", PositionLive.Index, :edit
    live "/positions/:id/close", PositionLive.Index, :close
    live "/positions/:id/roll", PositionLive.Index, :roll
    live "/positions/:id/reopen", PositionLive.Index, :reopen
    live "/positions/:id/delete", PositionLive.Index, :delete
    live "/positions/:id/notes", PositionLive.Index, :notes

    # Statistics
    live "/statistics", StatisticsLive.Index, :index
    live "/statistics/accounts/:account_id", StatisticsLive.Index, :index, as: :statistics_account_index
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
  import Phoenix.LiveDashboard.Router

  scope "/admin" do
    pipe_through [:browser, :admin]

    scope "/" do
      pipe_through [:csrf]
      live_dashboard "/dashboard", metrics: OptionsTrackerWeb.Telemetry, metrics_history: {LiveDashboardHistory, :metrics_history, [__MODULE__]}
    end

    # Cannot have csrf token or it will break
    forward "/errors", Flames.Web
  end

  ## Authentication routes

  scope "/", OptionsTrackerWeb do
    pipe_through [:browser, :csrf, :redirect_if_user_is_authenticated]

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
    get "/users/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
    get "/users/reset_password", UserResetPasswordController, :new
    post "/users/reset_password", UserResetPasswordController, :create
    get "/users/reset_password/:token", UserResetPasswordController, :edit
    put "/users/reset_password/:token", UserResetPasswordController, :update
  end

  scope "/", OptionsTrackerWeb do
    pipe_through [:browser, :csrf]

    scope "/" do
      pipe_through :full_width
      get "/", HomeController, :index
    end

    delete "/users/log_out", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :confirm
  end

  def restrict_admin(conn, []) do
    if conn.assigns.current_user.admin? do
      conn
    else
      conn
      |> put_status(:unauthorized)
      |> Phoenix.Controller.render(OptionsTrackerWeb.ErrorView, "404.html")
      |> halt
    end
  end
end
