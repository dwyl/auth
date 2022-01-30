defmodule Auth.Init do
  @moduledoc """
  Init as it's name suggests initializes the Auth Application 
  by creating the necessary records in the various tables.

  This is the sequence of steps that are followed to init the App:

  1. Create the "Super Admin" person who owns the Auth App
  based on the `ADMIN_EMAIL` environment/config variable.
  
  > The person.id for the Super Admin will own the remaining records
  so it needs to be created first. 

  2. Create default records (Statuses & Roles)

  3. Create the App and AUTH_API_KEY for the Auth App.
  """

  require Logger
  import Ecto.Changeset
  alias Auth.{Person, Role, Repo, Status}

  def main do
    Logger.debug("Initialising the Auth Database ...")
    # check required environment variables:
    Envar.is_set_all?(~w/ADMIN_EMAIL ENCRYPTION_KEYS SECRET_KEY_BASE/)

    admin = Auth.Init.create_admin()

    Auth.Init.insert_statuses()
    Auth.Init.create_default_roles()
    
    api_key = Auth.Init.create_apikey_for_admin(admin)

    # set the AUTH_API_KEY environment variable during test run:
    # IO.inspect(Mix.env(), label: "Mix.env()")
    # coveralls-ignore-start
    case Mix.env() do
      :test ->
        Envar.set("AUTH_API_KEY", api_key)

      _ ->
        Logger.info("export AUTH_API_KEY=#{api_key}")
    end
    # coveralls-ignore-stop
    
    # Update status of Admin to "Verified"
    Auth.Person.verify_person_by_id(1)
    
    # grant superadmin role to app owner:
    Auth.PeopleRoles.upsert(1, 1, 1, 1)

    :ok
  end


  # This is used exclusivvely during setup
  # don't confuse it with AuthPlug.get_auth_url/2
  defp get_auth_url do
    # see .env_sample for example
    Envar.get("AUTH_URL") || "localhost:4000"
  end

  def create_admin do
    email = Envar.get("ADMIN_EMAIL")
    case Person.get_person_by_email(email) do
      # Ignore if the Super Admin already exists:
      # coveralls-ignore-start
      nil ->
        %Person{}
        |> Person.changeset(%{email: email})
        # |> put_assoc(:statuses, [%Status{text: "verified"}])
        |> Repo.insert!()
      # coveralls-ignore-stop

      person ->
        person
    end
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

    key.client_id <> "/" <> key.client_secret <> "/" <> get_auth_url()
  end

  # scripts for creating default roles and permissions
  def get_json(filepath) do
    path = File.cwd!() <> filepath
    # IO.inspect(path, label: "path")
    {:ok, data} = File.read(path)
    json = Jason.decode!(data)
    json
  end

  def create_default_roles do
    Enum.each(get_json("/lib/auth/init/default_roles.json"), fn role ->
      Role.upsert_role(role)
    end)
  end

  def insert_statuses do
    Enum.each(get_json("/lib/auth/init/statuses.json"), fn status ->
      Status.upsert_status(status)
    end)
  end

end