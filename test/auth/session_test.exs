defmodule Auth.SessionTest do
  use AuthWeb.ConnCase, async: true

  test "Auth.Session.insert/1 inserts a session record", %{conn: conn} do
    # Note: Auth.Session.session_start/2 is invoked in test_helper.exs
    conn = non_admin_login(conn)
    session = Auth.Session.get(conn)

    assert session.app_id == conn.assigns.person.app_id
    assert session.person_id == conn.assigns.person.id
    assert session.auth_provider == conn.assigns.person.auth_provider
    assert session.end == nil
  end

  test "Auth.Session.start_session/1 inserts a session record", %{conn: conn} do
    # Note: Auth.Session.session_start/2 is invoked in test_helper.exs
    conn = conn |> non_admin_login()

    session = Auth.Session.get(conn)

    assert session.id == conn.assigns.sid
  end

  test "Auth.Session.get/1 retrieves a session record", %{conn: conn} do
    conn = non_admin_login(conn)

    # Retrieve the session from DB:
    session = Auth.Session.get(conn)
    assert session.app_id == conn.assigns.person.app_id
    assert session.person_id == conn.assigns.person.id
    assert session.auth_provider == conn.assigns.person.auth_provider
    assert session.end == nil
  end

  test "Auth.Session.update_session_end/1 updates the session record", %{conn: conn} do
    conn = non_admin_login(conn)
    session = Auth.Session.get(conn)
    
    # Initially the session.end is nil (i.e. not yet ended)
    assert session.end == nil

    # End the Session:
    updated = Auth.Session.update_session_end(conn)
    
    # Confirm the end value has been set.
    assert updated.end == updated.updated_at
  end

  test "Auth.Session.end_session/1 terminates the session", %{conn: conn} do
    conn = conn |> non_admin_login()
    session = Auth.Session.get(conn)
    # The Session is set on conn.assigns
    assert session.id == conn.assigns.sid

    # Initially the session.end is nil (i.e. not yet ended)
    assert session.end == nil

    # End the Session:
    conn = Auth.Session.end_session(conn)
    assert Map.get(conn.assigns, :sid) == nil
  end
end
