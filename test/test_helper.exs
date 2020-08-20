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
    AuthPlug.create_jwt_session(conn, person)
  end
end
