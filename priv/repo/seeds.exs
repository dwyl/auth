# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Auth.Repo.insert!(%Auth.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Auth.Person
alias Auth.Repo
IO.inspect(System.get_env("ADMIN_EMAIL"), label: "ADMIN_EMAIL")

%Person{email: System.get_env("ADMIN_EMAIL")}
|> Person.changeset(%{email: System.get_env("ADMIN_EMAIL")})
|> Repo.insert!()
