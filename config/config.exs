# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :options_tracker,
  ecto_repos: [OptionsTracker.Repo]

# Configures the endpoint
config :options_tracker, OptionsTrackerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "kcY9LnSofPsuxMahD0S1CALLRX094vXMujPaHWLmL/JOwK8Ta6i13crvePyoRG1T",
  render_errors: [view: OptionsTrackerWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: OptionsTracker.PubSub,
  live_view: [signing_salt: "9KhYzV3x"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  level: System.get_env("LOG_LEVEL") || "info",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :recaptcha,
    public_key: {:system, "OPTIONS_TRACKER_RECAPTCHA_SITE_KEY"},
    secret: {:system, "OPTIONS_TRACKER_RECAPTCHA_SECRET_KEY"},
    json_library: Jason

config :flames,
  repo: OptionsTracker.Repo,
  endpoint: OptionsTrackerWeb.Endpoint,
  table: "errors"

config :logger,
  backends: [:console, Flames.Logger]

config :live_dashboard_history, LiveDashboardHistory,
  router: OptionsTrackerWeb.Router,
  metrics: OptionsTrackerWeb.Telemetry,
  buffer_size: 250

config :money,
  # this allows you to do Money.new(100)
  default_currency: :USD,
  # change the default thousands separator for Money.to_string
  separator: ",",
  # change the default decimal delimeter for Money.to_string
  delimiter: ".",
  # don’t display the currency symbol in Money.to_string
  symbol: true,
  # position the symbol
  symbol_on_right: false,
  # add a space between symbol and number
  symbol_space: false,
  # display units after the delimeter
  fractional_unit: true,
  # display the insignificant zeros or the delimeter
  strip_insignificant_zeros: false

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
