defmodule AuthWeb.PeopleRolesTest do
  use Auth.DataCase

  test "Auth.PeopleRoles.insert/3 happy path" do
    # create a new person:
    alex = %{email: "alex_grant_role@gmail.com", auth_provider: "email"}
    grantee = Auth.Person.create_person(alex)
    role_id = 4
    # grant the "creator" role (id: 4) to the new person:
    Auth.PeopleRoles.insert(1, grantee.id, role_id)

    # confirm people_roles record exists:
    record = Auth.PeopleRoles.get_record(grantee.id, role_id)
    assert record.person_id == grantee.id
    assert record.role_id == role_id
    assert record.granter_id == 1

    # confirm person record has roles preloaded:
    person_with_role = Auth.Person.get_person_by_id(grantee.id)
    roles = RBAC.transform_role_list_to_string(person_with_role.roles)
    assert roles =~ Integer.to_string(role_id)

    # check the latest people_roles record:
    list = Auth.PeopleRoles.list_people_roles()
    pr = List.last(list)
    assert pr.granter_id == 1
    assert pr.person_id == grantee.id
  end

  test "Auth.PeopleRoles.revoke/3 revokes a role" do
    # create a new person:
    alex = %{email: "alex_revoke@gmail.com", auth_provider: "email"}
    grantee = Auth.Person.create_person(alex)
    role_id = 3
    # grant the role to the new person:
    Auth.PeopleRoles.insert(1, grantee.id, role_id)

    # confirm people_roles record exists:
    record = Auth.PeopleRoles.get_record(grantee.id, role_id)
    assert record.person_id == grantee.id
    assert record.role_id == role_id
    assert record.granter_id == 1

    # revoke the role!
    Auth.PeopleRoles.revoke(1, grantee.id, role_id)

    # confirm people_roles record was updated:
    record = Auth.PeopleRoles.get_record(grantee.id, role_id)
    assert record.revoker_id == 1
    assert not is_nil(record.revoked)
  end
end
