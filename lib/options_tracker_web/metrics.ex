defmodule OptionsTrackerWeb.Metrics do
  def count_users() do
    :telemetry.execute([:options_tracker, :users], %{count: OptionsTracker.Users.count()})
  end

  def count_positions() do
    :telemetry.execute([:options_tracker, :positions], %{
      count: OptionsTracker.Accounts.count_positions()
    })
  end
end
