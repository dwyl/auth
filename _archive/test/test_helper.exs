ExUnit.start(exclude: [:skip])
Ecto.Adapters.SQL.Sandbox.mode(Auth.Repo, :manual)

defmodule AuthTest do
  @moduledoc """
  Test helper functions :-)
  """
  @admin_email Envar.get("ADMIN_EMAIL")
  @app_data %{
    "name" => "Example App",
    "url" => "https://www.example.com",
    "status" => 3
  }
  @doc """
  add a valid JWT/session to the conn for routes that require auth as "SuperAdmin"
  """
  def admin_login(conn) do
    person = Auth.Person.get_person_by_email(@admin_email)
    conn = Auth.Session.start_session(conn, %{person | app_id: 1})

    data = %{
      id: person.id,
      email: person.email,
      auth_provider: person.auth_provider,
      app_id: 1,
      sid: conn.assigns.sid,
      username: "admin"
    }

    # IO.inspect(person, label: "person")
    AuthPlug.create_jwt_session(conn, data)
  end

  def non_admin_person() do
    rand = :rand.uniform(1_000_000)

    person = %{
      id: rand,
      email: "alex+#{rand}@gmail.com",
      givenName: "Alexander McAwesome",
      auth_provider: "email",
      password: "thiswillbehashed",
      github_id: "#{rand}",
      picture: "https://avatars3.githubusercontent.com/u/10835816",
      status: 1,
      app_id: 1,
      username: "alex#{rand}"
    }

    Auth.Person.upsert_person(person)
  end

  def non_admin_login(conn) do
    person = non_admin_person()
    conn = Auth.Session.start_session(conn, person)

    data = %{
      id: person.id,
      email: person.email,
      auth_provider: person.auth_provider,
      givenName: person.givenName,
      picture: person.picture,
      status: 1,
      app_id: 1,
      sid: conn.assigns.sid,
      username: person.username
    }

    AuthPlug.create_jwt_session(conn, data)
  end

  def create_app_for_person(person) do
    data = Map.merge(@app_data, %{"person_id" => person.id})
    {:ok, app} = Auth.App.create_app(data)
    app
  end
end
