# Script for populating the database. You can run it as:
#
# mix run priv/repo/seeds.exs
#
# The seeds.exs script will also run
# when you execute the following command
# to setup the database:
#
# mix ecto.setup
defmodule Auth.Seeds do
  alias Auth.{Person, Repo, Status}
  # put_assoc
  import Ecto.Changeset

  def create_admin do
    email = System.get_env("ADMIN_EMAIL")

    person =
      case Person.get_person_by_email(email) do
        nil ->
          %Person{}
          |> Person.changeset(%{email: email})
          |> put_assoc(:statuses, [%Status{text: "verified"}])
          |> Repo.insert!()

        person ->
          person
      end

    IO.inspect(person.id, label: "seeds.exs person.id")
    IO.puts("- - - - - - - - - - - - - - - - - - - - - - ")

    person
  end

  def create_apikey_for_admin(person) do
    {:ok, key} =
      %{
        "name" => "system admin key",
        "description" => "Created by /priv/repo/seeds.exs during setup.",
        # the default host in %Plug.Conn
        "url" => "www.example.com"
      }
      |> AuthWeb.ApikeyController.make_apikey(person.id)
      |> Auth.Apikey.create_apikey()

    api_key = key.client_id <> "/" <> key.client_secret
    # Set the AUTH_API_KEY to a valid value that is in the DB:
    System.put_env("AUTH_API_KEY", api_key)
    IO.inspect(System.get_env("AUTH_API_KEY"), label: "AUTH_API_KEY")
    IO.puts("- - - - - - - - - - - - - - - - - - - - - - ")
    key
  end
end

Auth.Seeds.create_admin()
|> Auth.Seeds.create_apikey_for_admin()
