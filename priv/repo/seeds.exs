require Logger
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
  import Ecto.Changeset

  def create_admin do
    if is_nil(System.get_env("TRAVIS")) && is_nil(System.get_env("HEROKU")) do
      load_env()
    end

    email = System.get_env("ADMIN_EMAIL")

    person =
      case Person.get_person_by_email(email) do
        nil ->
          %Person{}
          |> Person.changeset(%{email: email})
          # |> put_assoc(:statuses, [%Status{text: "verified"}])
          |> Repo.insert!()

        person ->
          person
      end

    if(Mix.env() == :test) do
      # don't print noise during tests
    else
      IO.inspect(person.id, label: "seeds.exs person.id")
      IO.puts("- - - - - - - - - - - - - - - - - - - - - - ")
    end

    person
  end

  def create_apikey_for_admin(person) do
    {:ok, app} =
      %{
        "name" => "default system app",
        "desc" => "Created by /priv/repo/seeds.exs during setup.",
        "url" => "localhost:4000",
        "person_id" => person.id,
        "status" => 3
      }
      |> Auth.App.create_app()

    # set the api key to AUTH_API_KEY in env:
    update_attrs = %{
      "client_id" => AuthPlug.Token.client_id(),
      "client_secret" => AuthPlug.Token.client_secret()
    }

    {:ok, key} =
      Auth.Apikey.get_apikey_by_app_id(app.id)
      |> cast(update_attrs, [:client_id, :client_secret])
      |> Repo.update()

    api_key = key.client_id <> "/" <> key.client_secret
    # set the AUTH_API_KEY environment variable during test run:
    IO.inspect(Mix.env(), label: "Mix.env()")
    # IO.inspect(person)
    case Mix.env() do
      :test ->
        System.put_env("AUTH_API_KEY", api_key)

      :prod ->
        Logger.info("export AUTH_API_KEY=#{api_key}")

      _ ->
        nil
    end
  end

  # load the .env file
  def load_env() do
    path = File.cwd!() <> "/.env"
    IO.inspect(path, label: ".env file path")
    {:ok, data} = File.read(path)

    Enum.map(String.split(data, "\n"), fn line ->
      line =
        line
        |> String.replace("export ", "")
        |> String.replace("'", "")

      # this part is convoluted because some .env values can contain "=" chacter:
      {index, _} = :binary.match(line, "=")
      len = String.length(line)
      value = String.slice(line, index + 1, len)
      [key | _rest] = String.split(line, "=")
      # IO.inspect(value, label: key)
      System.put_env(key, value)
    end)
  end
end

# scripts for creating default roles and permissions
defmodule SeedData do
  alias Auth.{Role, Status}

  def get_json(filepath) do
    path = File.cwd!() <> filepath
    {:ok, data} = File.read(path)
    json = Jason.decode!(data)
    json
  end

  def create_default_roles do
    Enum.each(get_json("/priv/repo/default_roles.json"), fn role ->
      Role.upsert_role(role)
    end)
  end

  def insert_statuses do
    Enum.each(get_json("/priv/repo/statuses.json"), fn status ->
      Status.upsert_status(status)
    end)
  end
end

person = Auth.Seeds.create_admin()
SeedData.insert_statuses()

Auth.Seeds.create_apikey_for_admin(person)

# Update status of Admin to "Verified"
Auth.Person.verify_person_by_id(1)

SeedData.create_default_roles()
# grant superadmin role to app owner:
Auth.PeopleRoles.insert(1, 1, 1, 1)
