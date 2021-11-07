defmodule Auth.SessionTest do
  use AuthWeb.ConnCase

  test "Auth.Session.insert/1 inserts a session record", %{conn: conn} do
    conn = non_admin_login(conn)
    session = Auth.Session.insert(conn)

    assert session.app_id == conn.assigns.person.app_id
    assert session.person_id == conn.assigns.person.id
    assert session.auth_provider == conn.assigns.person.auth_provider
    assert session.end_at == nil
  end

  test "Auth.Session.get/1 retrieves a session record", %{conn: conn} do
    conn = non_admin_login(conn)
    session = Auth.Session.insert(conn)

    # Retrieve the session from DB:
    ses = Auth.Session.get(conn)
    assert session.app_id == ses.app_id
    assert session.person_id == ses.person_id
    assert session.auth_provider == ses.auth_provider
    assert ses.end_at == nil
  end
end
