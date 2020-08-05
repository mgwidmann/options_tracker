defmodule OptionsTrackerWeb.Metrics do
  def count_users() do
    :telemetry.execute([:options_tracker, :users], %{count: OptionsTracker.Users.count()})
  end

  def count_online_users() do
    online_users = OptionsTrackerWeb.Presence.list("users")
    :telemetry.execute([:options_tracker, :users, :online], %{count: Enum.count(online_users)})
  end

  def count_positions() do
    :telemetry.execute([:options_tracker, :positions], %{
      count: OptionsTracker.Accounts.count_positions()
    })
  end

  def count_errors() do
    import Ecto.Query
    query = from e in Flames.Error, select: count(e.id)
    errors = OptionsTracker.Repo.one(query)

    :telemetry.execute([:options_tracker, :errors], %{count: errors})
  end
end
