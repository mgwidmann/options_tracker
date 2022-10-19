defmodule OptionsTrackerWeb.LayoutView do
  use OptionsTrackerWeb, :view

  def render("root.json", %{inner_content: inner_content}) do
    inner_content
  end
end
