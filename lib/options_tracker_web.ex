defmodule OptionsTrackerWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use OptionsTrackerWeb, :controller
      use OptionsTrackerWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: OptionsTrackerWeb

      import Plug.Conn
      import OptionsTrackerWeb.Gettext
      alias OptionsTrackerWeb.Router.Helpers, as: Routes
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/options_tracker_web/templates",
        namespace: OptionsTrackerWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1]

      # Include shared imports and aliases for views
      unquote(view_helpers())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {OptionsTrackerWeb.LayoutView, "live.html"}

      unquote(view_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(view_helpers())
      import OptionsTracker.Utilities.Maps
    end
  end

  def router do
    quote do
      use Phoenix.Router

      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
      import Redirect
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import OptionsTrackerWeb.Gettext
    end
  end

  defp view_helpers do
    quote do
      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML
      use PhoenixHtmlSanitizer, :basic_html

      # Import LiveView helpers (live_render, live_component, live_patch, etc)
      import Phoenix.Component
      import Phoenix.LiveView.Helpers
      import OptionsTrackerWeb.LiveHelpers

      # Import basic rendering functionality (render, render_layout, etc)
      import Phoenix.View

      import OptionsTrackerWeb.ErrorHelpers
      import OptionsTrackerWeb.Gettext
      alias OptionsTrackerWeb.Router.Helpers, as: Routes
      import OptionsTracker.Utilities.Maps
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
