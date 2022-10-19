defmodule OptionsTrackerWeb.Presence do
  use Phoenix.Presence,
    otp_app: :options_tracker,
    pubsub_server: OptionsTracker.PubSub
end
