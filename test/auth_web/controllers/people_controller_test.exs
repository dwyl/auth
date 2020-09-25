defmodule AuthWeb.PeopleControllerTest do
  use AuthWeb.ConnCase
  # @email System.get_env("ADMIN_EMAIL")

  test "GET /people displays list of people", %{conn: conn} do
    conn = admin_login(conn)
    # insert the admin person into the log:
    app_id = conn.assigns.person.app_id
    IO.inspect(conn.assigns.person)
    Auth.Log.info(conn, %{app_id: app_id, status_id: 200})
    # insert new person into log so it appears in people:
    person2 = non_admin_person()
    Auth.Log.info(conn,
      %{app_id: app_id, person_id: person2.id, status_id: 200, email: person2.email})

    conn = get(conn, "/people")
    assert html_response(conn, 200) =~ "People Authenticated"
  end

  test "Attempt to GET /people not unathenticated", %{conn: conn} do
    conn = get(conn, "/people")
    assert conn.status == 302
  end

  test "Non-admin can see /people relevant to their App(s)", %{conn: conn} do
    conn = non_admin_login(conn)
    person = conn.assigns.person
    app = create_app_for_person(person)
    # insert role for person (for the app):
    Auth.PeopleRoles.insert(app.id, person.id, person.id, 3)
    Auth.Log.info(conn, %{app_id: app.id, person_id: person.id, status_id: 200})
    # second non-admin person:
    person2 = non_admin_person()
    Auth.PeopleRoles.insert(app.id, person2.id, person.id, 3)
    # insert successful "login" entry in log table for person2:
    Auth.Log.info(conn, %{app_id: app.id, person_id: person2.id, status_id: 200})
    conn = get(conn, "/people")
    assert html_response(conn, 200) =~ "People Authenticated"
  end

  test "Non-admin without app cannot see any people", %{conn: conn} do
    conn = non_admin_login(conn)
    conn = get(conn, "/people")
    assert html_response(conn, 404) =~ "No People Using"
  end


  test "GET /people/:person_id displays person", %{conn: conn} do
    conn = get(admin_login(conn), "/people/1")
    assert html_response(conn, 200) =~ "Roles"
  end

  test "AuthWeb.PeopleView.status_string/2" do
    statuses = [%{text: "verified", id: 1}]
    assert AuthWeb.PeopleView.status_string(1, statuses) == "verified"
  end

  test "AuthWeb.PeopleView.status_string/2 if status_id is nil" do
    assert AuthWeb.PeopleView.status_string(nil, []) == "none"
  end

  test "AuthWeb.PeopleController.show/2 unauthorized if not admin", %{conn: conn} do
    conn = get(non_admin_login(conn), "/people/1")
    assert conn.status == 401
  end
end
