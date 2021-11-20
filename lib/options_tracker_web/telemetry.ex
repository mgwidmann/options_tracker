defmodule OptionsTrackerWeb.Telemetry do
  use Supervisor
  import Telemetry.Metrics

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      {:telemetry_poller, measurements: periodic_measurements(), period: 10_000}
      # Add reporters as children of your supervision tree.
      # {Telemetry.Metrics.ConsoleReporter, metrics: metrics()}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def metrics do
    [
      # Phoenix Metrics
      summary("phoenix.endpoint.stop.duration", unit: {:native, :millisecond}),
      summary("phoenix.router_dispatch.stop.duration", tags: [:route], unit: {:native, :millisecond}),

      # summary("phoenix.live_view.mount.start.system_time", unit: {:native, :millisecond}),
      # summary("phoenix.live_view.handle_params.start.system_time", unit: {:native, :millisecond}),
      # summary("phoenix.live_view.handle_event.start.system_time", unit: {:native, :millisecond}),
      # summary("phoenix.live_component.handle_event.start.system_time", unit: {:native, :millisecond}),

      summary("phoenix.live_view.mount.stop.duration", unit: {:native, :millisecond}),
      summary("phoenix.live_view.handle_params.stop.duration", unit: {:native, :millisecond}),
      summary("phoenix.live_view.handle_event.stop.duration", unit: {:native, :millisecond}),
      summary("phoenix.live_component.handle_event.stop.duration", unit: {:native, :millisecond}),
      summary("phoenix.live_view.mount.exception.duration", unit: {:native, :millisecond}),
      summary("phoenix.live_view.handle_params.exception.duration", unit: {:native, :millisecond}),
      summary("phoenix.live_view.handle_event.exception.duration", unit: {:native, :millisecond}),
      summary("phoenix.live_component.handle_event.exception.duration", unit: {:native, :millisecond}),

      # Database Metrics
      summary("db.repo.query.total_time", unit: {:native, :millisecond}),
      summary("db.repo.query.decode_time", unit: {:native, :millisecond}),
      summary("db.repo.query.query_time", unit: {:native, :millisecond}),
      summary("db.repo.query.queue_time", unit: {:native, :millisecond}),
      summary("db.repo.query.idle_time", unit: {:native, :millisecond}),

      # VM Metrics
      summary("vm.memory.total", unit: {:byte, :kilobyte}),
      summary("vm.total_run_queue_lengths.total"),
      summary("vm.total_run_queue_lengths.cpu"),
      summary("vm.total_run_queue_lengths.io"),

      # OptionsTracker Metrics
      last_value("options_tracker.total.count"),
      last_value("options_tracker.users.count"),
      last_value("options_tracker.users.online.count"),
      last_value("options_tracker.positions.count"),
      last_value("options_tracker.errors.count")
    ]
  end

  if Mix.env() == :prod do
    defp periodic_measurements do
      [
        # A module, function and arguments to be invoked periodically.
        # This function must call :telemetry.execute/3 and a metric must be added above.
        {OptionsTrackerWeb.Metrics, :count_users, []},
        {OptionsTrackerWeb.Metrics, :count_online_users, []},
        {OptionsTrackerWeb.Metrics, :count_positions, []},
        {OptionsTrackerWeb.Metrics, :count_errors, []},
        {OptionsTrackerWeb.Metrics, :count_total, []}
      ]
    end
  else
    # Dev and test is too noisy to have this running
    defp periodic_measurements do
      []
    end
  end
end
