defmodule Auth.CtxTest do
  use Auth.DataCase

  alias Auth.Ctx

  describe "roles" do
    alias Auth.Ctx.Role

    @valid_attrs %{desc: "some desc", name: "some name"}
    @update_attrs %{desc: "some updated desc", name: "some updated name"}
    @invalid_attrs %{desc: nil, name: nil}

    def role_fixture(attrs \\ %{}) do
      {:ok, role} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Ctx.create_role()

      role
    end

    test "list_roles/0 returns all roles" do
      role = role_fixture()
      assert Ctx.list_roles() == [role]
    end

    test "get_role!/1 returns the role with given id" do
      role = role_fixture()
      assert Ctx.get_role!(role.id) == role
    end

    test "create_role/1 with valid data creates a role" do
      assert {:ok, %Role{} = role} = Ctx.create_role(@valid_attrs)
      assert role.desc == "some desc"
      assert role.name == "some name"
    end

    test "create_role/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Ctx.create_role(@invalid_attrs)
    end

    test "update_role/2 with valid data updates the role" do
      role = role_fixture()
      assert {:ok, %Role{} = role} = Ctx.update_role(role, @update_attrs)
      assert role.desc == "some updated desc"
      assert role.name == "some updated name"
    end

    test "update_role/2 with invalid data returns error changeset" do
      role = role_fixture()
      assert {:error, %Ecto.Changeset{}} = Ctx.update_role(role, @invalid_attrs)
      assert role == Ctx.get_role!(role.id)
    end

    test "delete_role/1 deletes the role" do
      role = role_fixture()
      assert {:ok, %Role{}} = Ctx.delete_role(role)
      assert_raise Ecto.NoResultsError, fn -> Ctx.get_role!(role.id) end
    end

    test "change_role/1 returns a role changeset" do
      role = role_fixture()
      assert %Ecto.Changeset{} = Ctx.change_role(role)
    end
  end
end
