defmodule OptionsTrackerWeb.Router do
  use OptionsTrackerWeb, :router

  import OptionsTrackerWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :csrf do
    plug :protect_from_forgery
  end

  pipeline :standard_width do
    plug :put_root_layout, {OptionsTrackerWeb.LayoutView, :root}
  end

  pipeline :admin do
    plug :restrict_admin
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  if Mix.env == :dev do
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end

  # Authenticated routes
  scope "/", OptionsTrackerWeb do
    pipe_through [:browser, :standard_width, :csrf, :require_authenticated_user]

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

    # Positions & Shares
    live "/positions", PositionLive.Index, :index
    live "/positions/shares", ShareLive.Index, :index
    live "/positions/accounts/:account_id", PositionLive.Index, :index, as: :position_account_index
    live "/positions/accounts/:account_id/new", PositionLive.Index, :new
    live "/positions/:id/edit", PositionLive.Index, :edit
    live "/positions/:id/close", PositionLive.Index, :close
    live "/positions/:id/expire", PositionLive.Index, :expire
    live "/positions/:id/exercise", PositionLive.Index, :exercise
    live "/positions/:id/roll", PositionLive.Index, :roll
    live "/positions/:id/reopen", PositionLive.Index, :reopen
    live "/positions/:id/delete", PositionLive.Index, :delete
    live "/positions/:id/notes", PositionLive.Index, :notes


    # Metrics
    live "/metrics", StatisticsLive.Index, :index
    live "/metrics/accounts/:account_id", StatisticsLive.Index, :index, as: :statistics_account_index
  end

  redirect "/statistics", "/metrics", :permanent
  redirect "/statistics/accounts/:account_id", "/metrics", :permanent

  # Public routes
  scope "/", OptionsTrackerWeb do
    pipe_through [:browser, :standard_width, :csrf]

    live "/shares", ShareLive.Show, :show
    live "/metrics/public/accounts/:account_id", StatisticsLive.Index, :index, as: :public_statistics_account_index
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
    pipe_through [:browser, :standard_width, :admin]

    scope "/" do
      pipe_through [:csrf]
      live_dashboard "/dashboard", metrics: OptionsTrackerWeb.Telemetry, metrics_history: {LiveDashboardHistory, :metrics_history, [__MODULE__]}

      live "/feedback", OptionsTrackerWeb.FeedbackLive.Index, :index
    end

    # Cannot have csrf token or it will break
    forward "/errors", Flames.Web
  end

  ## Authentication routes

  scope "/", OptionsTrackerWeb do
    pipe_through [:browser, :standard_width, :csrf, :redirect_if_user_is_authenticated]

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
    get "/users/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
    post "/users/demo/log_in", UserSessionController, :demo_create
    get "/users/reset_password", UserResetPasswordController, :new
    post "/users/reset_password", UserResetPasswordController, :create
    get "/users/reset_password/:token", UserResetPasswordController, :edit
    put "/users/reset_password/:token", UserResetPasswordController, :update
  end

  scope "/", OptionsTrackerWeb do
    pipe_through [:browser, :csrf]

    scope "/" do
      get "/", HomeController, :index
    end

    scope "/" do
      pipe_through [:standard_width]
      delete "/users/log_out", UserSessionController, :delete
      get "/users/confirm", UserConfirmationController, :new
      post "/users/confirm", UserConfirmationController, :create
      get "/users/confirm/:token", UserConfirmationController, :confirm
    end
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
