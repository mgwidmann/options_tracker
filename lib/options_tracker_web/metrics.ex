defmodule OptionsTrackerWeb.Metrics do
  require Logger

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

  def count_total() do
    :telemetry.execute([:options_tracker, :total], %{count: count_all_records()})
  end

  def count_all_records() do
    %Postgrex.Result{rows: rows} = Ecto.Adapters.SQL.query!(
      OptionsTracker.Repo, """
        SELECT schemaname, relname, n_live_tup
        FROM pg_stat_user_tables
        ORDER BY n_live_tup DESC
      """
    )

    counts = rows
      |> Enum.reduce(%{}, fn ([_schema, table, count], map) -> Map.put_new(map, table, count) end)

    total = counts
      |> Enum.map(fn {_table, count} -> count end)
      |> Enum.sum()

    Logger.info("Record counts by table (total #{total}): #{inspect counts}")

    total
  end
end
