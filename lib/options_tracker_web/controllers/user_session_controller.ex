defmodule OptionsTrackerWeb.UserSessionController do
  use OptionsTrackerWeb, :controller

  alias OptionsTracker.Users
  alias OptionsTrackerWeb.UserAuth

  def new(conn, _params) do
    render(conn, "new.html", error_message: nil)
  end

  def create(conn, %{"user" => user_params}) do
    %{"email" => email, "password" => password} = user_params

    if user = Users.get_user_by_email_and_password(email, password) do
      UserAuth.log_in_user(conn, user, user_params)
    else
      render(conn, "new.html", error_message: "Invalid e-mail or password")
    end
  end


  def demo_create(conn, params) do
    case Recaptcha.verify(params["g-recaptcha-response"]) do
      {:ok, _response} ->
        login_demo_user(conn)
      {:error, _errors} ->
        render(conn, "new.html", error_message: "Invalid e-mail or password")
    end
  end

  defp login_demo_user(conn) do
    if user = Users.get_demo_user() do
      UserAuth.log_in_user(conn, user)
    else
      render(conn, "new.html", error_message: "Invalid e-mail or password")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
