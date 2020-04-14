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
  import Ecto.Changeset # put_assoc
  IO.inspect(System.get_env("ADMIN_EMAIL"), label: "ADMIN_EMAIL")

  def create_admin do
    person = %Person{email: System.get_env("ADMIN_EMAIL")}
    |> Person.changeset(%{email: System.get_env("ADMIN_EMAIL")})
    |> put_assoc(:statuses, [%Status{text: "verified"}])
    |> Repo.insert!()

    IO.inspect(person, label: "first person")
  end
end

Auth.Seeds.create_admin()
