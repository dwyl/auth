defmodule Auth.GroupTest do
  use Auth.DataCase, async: true

  describe "Group Schema Tests" do
    test "Auth.Group.create/1 creates a new group" do
      group = %{
        desc: "My test group",
        name: "TestGroup",
        kind: 1
      }
      assert {:ok, inserted_group} = Auth.Group.create(group)
      assert inserted_group.name == group.name
    end
  end
end
