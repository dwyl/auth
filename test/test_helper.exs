ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Auth.Repo, :manual)

defmodule AuthTest do
  @moduledoc """
  Test helper functions :-)
  """
  @admin_email System.get_env("ADMIN_EMAIL")
  @doc """
  add a valid JWT/session to the conn for routes that require auth as "SuperAdmin"
  """
  def admin_login(conn) do
    person = Auth.Person.get_person_by_email(@admin_email)
    data = %{
      id: person.id,
      email: person.email,
      auth_provider: person.auth_provider
    }
    # IO.inspect(person, label: "person")
    AuthPlug.create_jwt_session(conn, data)
  end
end
