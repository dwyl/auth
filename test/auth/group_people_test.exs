defmodule Auth.GroupPeopleTest do
  use Auth.DataCase, async: true

  describe "Group People Schema Tests" do
    test "Auth.GroupPeople.create/1 creates a new group" do
      # admin, app & role created by init. see: Auth.Init.main/0
      app = Auth.App.get_app!(1)
      admin = Auth.Person.get_person_by_id(1)

      # Create group
      group = %{
        desc: "Group with people",
        name: "GroupName",
        kind: 1,
        app_id: app.id
      }
      assert {:ok, inserted_group} = Auth.Group.create(group)
      assert inserted_group.name == group.name
      assert inserted_group.app_id == app.id

      # Create a random non-admin person we can add to the group:
      alex = %{email: "alex_not_admin@gmail.com", givenName: "Alex",
                auth_provider: "email", app_id: app.id}
      non_admin = Auth.Person.create_person(alex)
      assert non_admin.id > 1

      group_person = %{
        granter_id: admin.id,
        group_id: inserted_group.id,
        person_id: non_admin.id,
        role_id: 4
      }

      # Insert the GroupPerson Record
      {:ok, gp} = Auth.GroupPeople.create(group_person)
      assert gp.group_id == inserted_group.id
      assert gp.person_id == non_admin.id

      # Insert the GroupPerson Admin
      group_person_admin = %{
        granter_id: admin.id,
        group_id: inserted_group.id,
        person_id: admin.id,
        role_id: 2
      }

      {:ok, inserted_group_admin} = Auth.GroupPeople.create(group_person_admin)
      assert inserted_group_admin.group_id == inserted_group.id
      assert inserted_group_admin.person_id == admin.id

      # Finally, let's confirm these two people are in the group:
      group_people = Auth.GroupPeople.get_group_people(inserted_group.id)
      assert Enum.count(group_people) == 2
    end
  end
end
