defmodule AuthWeb.PeopleRolesTest do
  use Auth.DataCase

  test "Auth.PeopleRoles.insert/3 happy path" do
    # create a new person:
    alex = %{email: "alex_grant_role@gmail.com", auth_provider: "email"}
    grantee = Auth.Person.create_person(alex)
    role_id = 4
    # grant the "creator" role (id: 4) to the new person:
    Auth.PeopleRoles.insert(1, grantee.id, role_id)
    person_with_role = Auth.Person.get_person_by_id(grantee.id)
    roles = RBAC.transform_role_list_to_string(person_with_role.roles)
    assert roles =~ Integer.to_string(role_id)

    # check the latest people_roles record:
    list = Auth.PeopleRoles.list_people_roles() |> IO.inspect()
    # IO.inspect(list, label: "list")
    pr = List.last(list)
    assert pr.granter_id == 1
    assert pr.person_id == grantee.id
  end

  # test "Auth.PeopleRoles.revoke/3 "
end
