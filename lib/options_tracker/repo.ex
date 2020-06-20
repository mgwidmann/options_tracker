defmodule OptionsTracker.Repo do
  use Ecto.Repo,
    otp_app: :options_tracker,
    adapter: Ecto.Adapters.Postgres
end
