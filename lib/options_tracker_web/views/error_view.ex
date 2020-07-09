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
    render("404.html", %{
      template: String.replace(template, ".html", ""),
      message: Phoenix.Controller.status_message_from_template(template)
    })
  end

  def render("404.html", assigns) do
    template = Map.get(assigns, :template, "404")
    message = Map.get(assigns, :message, Phoenix.Controller.status_message_from_template("404.html"))
    ~E"""
    <div class="section has-text-centered">
      <div class="title">
        <%= template %>&nbsp;<%= message %>
      </div>
    </div>
    """
  end
end
