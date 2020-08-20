defmodule AuthWeb.RoleControllerTest do
  use AuthWeb.ConnCase

  alias Auth.Role

  @create_attrs %{desc: "some desc", name: "some name"}
  @update_attrs %{desc: "some updated desc", name: "some updated name"}
  @invalid_attrs %{desc: nil, name: nil}

  def fixture(:role) do
    {:ok, role} = Role.create_role(@create_attrs)
    role
  end

  describe "index" do
    test "lists all roles", %{conn: conn} do
      conn = admin_login(conn) |> get(Routes.role_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Roles"
    end
  end

  describe "new role" do
    test "renders form", %{conn: conn} do
      conn = admin_login(conn) |> get(Routes.role_path(conn, :new))
      assert html_response(conn, 200) =~ "New Role"
    end
  end

  describe "create role" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn =
        admin_login(conn)
        |> post(Routes.role_path(conn, :create), role: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.role_path(conn, :show, id)

      conn = get(conn, Routes.role_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Role"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        admin_login(conn)
        |> post(Routes.role_path(conn, :create), role: @invalid_attrs)

      assert html_response(conn, 200) =~ "New Role"
    end
  end

  describe "edit role" do
    setup [:create_role]

    test "renders form for editing chosen role", %{conn: conn, role: role} do
      conn =
        admin_login(conn)
        |> get(Routes.role_path(conn, :edit, role))

      assert html_response(conn, 200) =~ "Edit Role"
    end
  end

  describe "update role" do
    setup [:create_role]

    test "redirects when data is valid", %{conn: conn, role: role} do
      conn =
        admin_login(conn)
        |> put(Routes.role_path(conn, :update, role), role: @update_attrs)

      assert redirected_to(conn) == Routes.role_path(conn, :show, role)

      conn = get(conn, Routes.role_path(conn, :show, role))
      assert html_response(conn, 200) =~ "some updated desc"
    end

    test "renders errors when data is invalid", %{conn: conn, role: role} do
      conn =
        admin_login(conn)
        |> put(Routes.role_path(conn, :update, role), role: @invalid_attrs)

      assert html_response(conn, 200) =~ "Edit Role"
    end
  end

  describe "delete role" do
    setup [:create_role]

    test "deletes chosen role", %{conn: conn, role: role} do
      conn =
        admin_login(conn)
        |> delete(Routes.role_path(conn, :delete, role))

      assert redirected_to(conn) == Routes.role_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.role_path(conn, :show, role))
      end
    end
  end

  defp create_role(_) do
    role = fixture(:role)
    %{role: role}
  end
end
