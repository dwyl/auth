defmodule Auth.EmailController do
  use Auth.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def create(conn, %{"email" => %{"email_from" => email_from,
  "subject" => subject, "message" => message}}) do
    Auth.Email.send_test_email(email_from, subject, message)
    |> Auth.Mailer.deliver_now()

    conn
    |> put_flash(:info, "Email Sent")
    |> redirect(to: email_path(conn, :index))
  end
end
