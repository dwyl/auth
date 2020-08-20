defmodule AuthWeb.PeopleRolesTest do
  use AuthWeb.ConnCase

  test "grant_role/3 happy path", %{conn: conn} do
    # login as superadmin
    conn = AuthTest.admin_login(conn)
    # create a new person 
    alex = %{email: "alex_grant_role@gmail.com", auth_provider: "email"}
    grantee = Auth.Person.create_person(alex)
    role_id = 4
    Auth.PeopleRoles.grant_role(conn, grantee.id, role_id)
    person_with_role = Auth.Person.get_person_by_id(grantee.id)
    role = List.first(person_with_role.roles)
    assert role_id == role.id
  end

  test "attempt to grant_role/3 without admin should 401", %{conn: conn} do
    alex = %{email: "alex_grant_role_fail@gmail.com", auth_provider: "email"}
    grantee = Auth.Person.create_person(alex)
    conn = assign(conn, :person, grantee)
    role_id = 4
    conn = Auth.PeopleRoles.grant_role(conn, grantee.id, role_id)

    assert conn.status == 401
  end
end
