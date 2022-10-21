defmodule OptionsTracker.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      OptionsTracker.Repo,
      # Start up the flames supervisor after the repo is available
      Flames.Supervisor,
      # Start the Telemetry supervisor
      OptionsTrackerWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: OptionsTracker.PubSub},
      OptionsTrackerWeb.Presence,
      # Start the Endpoint (http/https)
      OptionsTrackerWeb.Endpoint,
      # Start a worker by calling: OptionsTracker.Worker.start_link(arg)
      {OptionsTracker.TableCleaner, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: OptionsTracker.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    OptionsTrackerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
