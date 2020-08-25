defmodule AuthWeb.PeopleControllerTest do
  use AuthWeb.ConnCase
  # @email System.get_env("ADMIN_EMAIL")

  test "GET /people displays list of people", %{conn: conn} do
    conn = get(admin_login(conn)"/people")
    assert html_response(conn, 200) =~ "People Authenticated"
  end

  test "Attempt to GET /people not unathenticated", %{conn: conn} do
    conn = get(conn, "/people")
    assert conn.status == 302
  end


  test "Attempt to GET /people without admin role should 401", %{conn: conn} do
    wrong_person_data = %{
      email: "not_admin@gmail.com",
      auth_provider: "email",
      id: 42
    }

    Auth.Person.create_person(wrong_person_data)
    conn = AuthPlug.create_jwt_session(conn, wrong_person_data)

    conn = get(conn, "/people")
    assert conn.status == 401
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
    wrong_person_data = %{
      email: "unauthorized@gmail.com",
      auth_provider: "email",
      id: 42
    }

    Auth.Person.create_person(wrong_person_data)
    conn = AuthPlug.create_jwt_session(conn, wrong_person_data)

    conn = AuthWeb.PeopleController.show(conn, %{"people_roles_id" => 1})
    assert conn.status == 401
  end
end
