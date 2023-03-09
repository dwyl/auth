defmodule AuthWeb.PersonSessionController do
  use AuthWeb, :controller

  alias Auth.Accounts
  alias AuthWeb.PersonAuth

  def new(conn, _params) do
    render(conn, :new, error_message: nil)
  end

  def create(conn, %{"person" => person_params}) do
    %{"email" => email, "password" => password} = person_params

    if person = Accounts.get_person_by_email_and_password(email, password) do
      conn
      |> put_flash(:info, "Welcome back!")
      |> PersonAuth.log_in_person(person, person_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      render(conn, :new, error_message: "Invalid email or password")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> PersonAuth.log_out_person()
  end
end
