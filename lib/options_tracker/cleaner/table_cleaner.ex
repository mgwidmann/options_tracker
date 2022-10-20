defmodule OptionsTracker.TableCleaner do
  use GenServer
  alias OptionsTracker.Cleaner
  require Logger

  @check 60_000 * (if Mix.env == :dev, do: 1, else: 10)
  @max_records (if Mix.env == :dev, do: 1, else: 9_500)

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, [name: :cleaner])
  end

  @impl true
  def init(:ok) do
    :timer.send_interval(@check, self(), :count)
    IO.inspect(["Sending self:", self(), :count])
    send(self(), :count)
    {:ok, %{total: -1, clean_failure: false}}
  end

  @impl true
  def handle_info(:count, state) do
    count = OptionsTrackerWeb.Metrics.count_all_records()

    if count >= @max_records do
      send(self(), :clean)
    end

    {:noreply, Map.put(state, :total, count)}
  end

  @impl true
  def handle_info(:clean, state) do
    total = 0
    {cleaned, _} = Cleaner.clean(OptionsTracker.Audits.Position, 90)
    total = total + cleaned
    Logger.info("Cleaned #{inspect cleaned} records from the positions_audits table")
    {cleaned, _} = Cleaner.clean("users_tokens", 60)
    total = total + cleaned
    Logger.info("Cleaned #{cleaned} records from the users_tokens table")
    {cleaned, _} = Cleaner.clean("errors", 180)
    total = total + cleaned
    Logger.info("Cleaned #{cleaned} records from the errors table")

    if total <= 0 do
      Logger.warn("CLEANING FAILURE!!!!! Database is getting too large with #{inspect state.total} records!")
      {:noreply, Map.put(state, :clean_failure, true)}
    else
      {:noreply, state}
    end

  end

  @impl true
  def handle_call(:check, _from, state) do
    {:reply, state, state}
  end

  def check() do
    GenServer.call(:cleaner, :check)
  end

  def system_failure?() do
    check().clean_failure
  end
end
