defmodule AuthWeb.PersonRegistrationController do
  use AuthWeb, :controller

  alias Auth.Accounts
  alias Auth.Accounts.Person
  alias AuthWeb.PersonAuth

  def new(conn, _params) do
    changeset = Accounts.change_person_registration(%Person{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"person" => person_params}) do
    case Accounts.register_person(person_params) do
      {:ok, person} ->
        {:ok, _} =
          Accounts.deliver_person_confirmation_instructions(
            person,
            &url(~p"/people/confirm/#{&1}")
          )

        conn
        |> put_flash(:info, "Person created successfully.")
        |> PersonAuth.log_in_person(person)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end
end
