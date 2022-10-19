defmodule OptionsTrackerWeb.UserEmail do
  use Bamboo.Phoenix, view: OptionsTrackerWeb.EmailView

  def password_reset(user, url) do
    new_email(
      to: user.email,
      from: "noreply@options-tracker.gigalixirapp.com",
      subject: "Welcome to the app.",
    )
    |> put_layout({OptionsTrackerWeb.LayoutView, :email})
    |> assign(:user, user)
    |> assign(:url, url)
    |> render(:password_reset)
  end
end
