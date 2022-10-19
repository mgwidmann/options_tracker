use Mix.Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :options_tracker, OptionsTracker.Repo,
  username: "postgres",
  password: "postgres",
  database: "options_tracker_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  telemetry_prefix: [:db, :repo],
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :options_tracker, OptionsTrackerWeb.Endpoint,
  http: [port: 4002],
  server: false

config :options_tracker,
  share_salt: "$2b$12$txHVZq/AWN2Yo1K9FRpO7u"

# Print only warnings and errors during test
config :logger, level: :warn

config :options_tracker, OptionsTrackerWeb.Mailer,
  adapter: Bamboo.LocalAdapter
