defmodule OptionsTrackerWeb.ErrorView do
  use OptionsTrackerWeb, :view

  # If you want to customize a particular status code
  # for a certain format, you may uncomment below.
  # def render("500.html", _assigns) do
  #   "Internal Server Error"
  # end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.html" becomes
  # "Not Found".
  def template_not_found(template, _assigns) do
    render("404.html", %{status: 404})
  end

  def emoji_for_status(404), do: "🔍"
  def emoji_for_status(_), do: "😢"
end
