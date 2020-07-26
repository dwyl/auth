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
    if(Mix.env() == :test) do
      # don't print noise during tests
    else
      IO.inspect(person.id, label: "seeds.exs person.id")
      IO.puts("- - - - - - - - - - - - - - - - - - - - - - ")
    end
    person
  end

  def create_apikey_for_admin(person) do
    {:ok, key} =
      %{
        "name" => "system admin key",
        "description" => "Created by /priv/repo/seeds.exs during setup.",
        "url" => "localhost:4000"
      }
      |> AuthWeb.ApikeyController.make_apikey(person.id)
      |> Auth.Apikey.create_apikey()

    api_key = key.client_id <> "/" <> key.client_secret
    # set the AUTH_API_KEY environment variable during test run:
    write_env("AUTH_API_KEY", api_key)
  end

  # write the key:value pair to project .env file
  def write_env(key, value) do
    # IO.inspect(File.cwd!, label: "cwd")
    path = File.cwd! <> "/.env"
    IO.inspect(path, label: ".env file path")
    {:ok, data} = File.read(path)
    # IO.inspect(data)

    lines = String.split(data, "\n") 
    |> Enum.filter(fn line -> 
      not String.contains?(line, key)  
    end)
    str = "export #{key}=#{value}" # |> IO.inspect
    vars = lines ++ [str]
    content = Enum.join(vars, "\n")
    File.write!(path, content) |> File.close()
    env(vars)
  end

  # export all the environment variables during app excution/tests
  def env(vars) do
    Enum.map(vars, fn line ->
      parts = line
      |> String.replace("export ", "")
      |> String.replace("'", "")
      |> String.split("=")

      # IO.inspect(List.last(parts), label: List.first(parts))
      System.put_env(List.first(parts), List.last(parts))
    end)
  end
end

Auth.Seeds.create_admin()
|> Auth.Seeds.create_apikey_for_admin()


# scripts for creating default roles and permissions
defmodule SetupRoles do
  alias Auth.Role

  def get_json(filepath) do
    # IO.inspect(filepath, label: "filepath")
    path = File.cwd! <> filepath
    # IO.inspect(path, label: "path")
    {:ok, data} = File.read(path)
    json = Jason.decode!(data)
    # IO.inspect(json)
    json
  end

  def create_default_roles() do
    json = get_json("/priv/repo/default_roles.json")
    Enum.each(json, fn role -> 
      Role.create_role(role)
    end)
  end

  
end

SetupRoles.create_default_roles()