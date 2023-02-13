defmodule Auth.Init do
  @moduledoc """
  `Init` as its' name suggests initializes the Auth Application 
  by creating the necessary records in the various tables.

  This is the sequence of steps that are followed to init the App:

  1. Create the "Super Admin" person who owns the Auth App
  based on the `ADMIN_EMAIL` environment/config variable.

  > The person.id (1) for the Super Admin 
  will own the remaining records so it needs to be created first. 

  2. Create default records (Statuses & Roles)

  3. Create the App and `AUTH_API_KEY` for the Auth App.
  > Log the `AUTH_API_KEY` so that it can be exported.
  """

  require Logger
  import Ecto.Changeset
  alias Auth.{Person, Repo}

  def main do
    Logger.info("Initialising the Auth Database ...")

    # if the #1 App does not exist, create it:
    api_key =
      case Auth.App.get_app!(1) do
        nil ->
          admin = Auth.Init.create_admin()

          # Create Generic Roles & Statuses
          Auth.InitStatuses.insert_statuses()
          Auth.InitRoles.create_default_roles()

          # Update status of Admin to "verified"
          Auth.Person.verify_person_by_id(admin.id)

          # Create App and API Key for the admin:
          Auth.Init.create_apikey_for_admin(admin)

        app ->
          key = List.last(app.apikeys)
          key.client_id <> "/" <> key.client_secret <> "/" <> get_auth_url()
      end

    case Envar.get("MIX_ENV") do
      "test" ->
        # set the AUTH_API_KEY environment variable during test run:
        Envar.set("AUTH_API_KEY", api_key)

      # ignore the next lines because we can't test them:
      # coveralls-ignore-start
      _ ->
        # Log the AUTH_API_KEY so it can be exported:
        Logger.info("export AUTH_API_KEY=#{api_key}")
        # coveralls-ignore-stop
    end

    :ok
  end

  # Get AUTH_URL or fallback to localhost:
  defp get_auth_url do
    # see .env_sample for example
    Envar.get("AUTH_URL") || "localhost:4000"
  end

  def create_admin do
    email = Envar.get("ADMIN_EMAIL")
    Logger.debug("ADMIN_EMAIL:#{email}")

    case Person.get_person_by_email(email) do
      # Ignore if the Super Admin already exists:
      nil ->
        %Person{}
        |> Person.changeset(%{email: email})
        |> Repo.insert!()

      person ->
        person
    end
  end

  def create_apikey_for_admin(person) do
    {:ok, app} =
      %{
        "name" => "default system app",
        "desc" => "Created by lib/auth/init/init.ex during setup.",
        "url" => "localhost:4000",
        "person_id" => person.id,
        "status" => 3
      }
      |> Auth.App.create_app()

    # Self-grant superadmin role to App "owner":
    Auth.PeopleRoles.upsert(app.id, person.id, person.id, 1)

    # If AUTH_API_KEY environment variable is already set, use it:
    key =
      if Envar.is_set?("AUTH_API_KEY") do
        update_attrs = %{
          "client_id" => AuthPlug.Token.client_id(),
          "client_secret" => AuthPlug.Token.client_secret()
        }

        # Update value of client_id & client_secret in the DB to match Env.
        {:ok, key} =
          Auth.Apikey.get_apikey_by_app_id(app.id)
          |> cast(update_attrs, [:client_id, :client_secret])
          |> Repo.update()

        key

        # coveralls-ignore-start
      else
        List.last(app.apikeys)
        # coveralls-ignore-stop
      end

    key.client_id <> "/" <> key.client_secret <> "/" <> get_auth_url()
  end
end
