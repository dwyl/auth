defmodule Auth.GroupTest do
  use Auth.DataCase, async: true

  describe "Group Schema Tests" do
    test "Auth.Group.create/1 creates a new group" do
      group = %{
        desc: "My test group",
        name: "TestGroup",
        kind: 1,
        app_id: 1
      }
      assert {:ok, inserted_group} = Auth.Group.create(group)
      assert inserted_group.name == group.name
    end

    @tag :skip
    test "Auth.Group.list_groups_for_person/1 gets groups a person belongs to" do
      group = %{
        desc: "Group 1 desc",
        name: "Group1",
        kind: 1,
        app_id: 1
      }
      assert {:ok, inserted_group} = Auth.Group.create(group)
      assert inserted_group.name == group.name

      admin = Auth.Person.get_person_by_id(1)
      # Insert the GroupPerson Admin
      group_person_admin = %{
        granter_id: admin.id,
        group_id: inserted_group.id,
        person_id: admin.id,
        role_id: 2
      }

      {:ok, _inserted_group_admin} = Auth.GroupPeople.create(group_person_admin)

      # Confirm the admin is a member of the group:
      person_with_groups = Auth.Person.get_person_by_id(1)
      assert Useful.typeof(person_with_groups.groups) == "list"
      g = List.first(person_with_groups.groups)
      assert g.name == group.name
    end
  end
end
