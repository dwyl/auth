defmodule AuthWeb.PeopleRolesTest do
  use Auth.DataCase, async: true

  test "Auth.PeopleRoles.insert/4 happy path" do
    app_id = 1
    # create a new person:
    grantee = AuthTest.non_admin_person()
    granter_id = 1
    role_id = 4
    # grant the "creator" role (id: 4) to the new person:
    Auth.PeopleRoles.insert(app_id, grantee.id, granter_id, role_id)

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

  test "Auth.PeopleRoles.upsert/4 when record doesn't exist" do
    # create a new person:
    person = AuthTest.non_admin_person()
    app = AuthTest.create_app_for_person(person)
    app_id = app.id
    grantee_id = person.id
    granter_id = 1
    role_id = 5
    # grant the "commenter" role (id: 5) to the new person:
    Auth.PeopleRoles.upsert(app_id, grantee_id, granter_id, role_id)
    # IO.inspect(pr, label: "39 pr:")

    # # confirm people_roles record exists:
    record = Auth.PeopleRoles.get_record(grantee_id, role_id)
    # IO.inspect(record, label: "42 record")
    assert record.person_id == grantee_id
    assert record.granter_id == 1

    # confirm person record has roles preloaded:
    person_with_role = Auth.Person.get_person_by_id(grantee_id)
    roles = RBAC.transform_role_list_to_string(person_with_role.roles)
    assert roles =~ Integer.to_string(role_id)

    # check the latest people_roles record:
    list = Auth.PeopleRoles.list_people_roles()
    pr = List.last(list)
    assert pr.granter_id == granter_id

    # Insert another role for the person to test branch
    role2_id = 4
    Auth.PeopleRoles.upsert(app_id, grantee_id, granter_id, role2_id)
    
    list = Auth.PeopleRoles.list_people_roles()
    retrieved = List.last(list)
    assert retrieved.role_id == role2_id
    assert retrieved.granter_id == granter_id

  end

  test "Auth.PeopleRoles.revoke/2 revokes a role" do
    app_id = 1
    # create a new person:
    grantee = non_admin_person()
    granter_id = 1
    role_id = 3
    # grant the role to the new person:
    Auth.PeopleRoles.insert(app_id, grantee.id, granter_id, role_id)

    # confirm people_roles record exists:
    record = Auth.PeopleRoles.get_record(grantee.id, role_id)
    assert record.person_id == grantee.id
    assert record.role_id == role_id
    assert record.granter_id == 1

    # revoke the role!
    Auth.PeopleRoles.revoke(1, record.id)

    # confirm people_roles record was updated:
    record = Auth.PeopleRoles.get_record(grantee.id, role_id)
    assert record.revoker_id == 1
    assert not is_nil(record.revoked)
  end
end
