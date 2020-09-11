defmodule AuthWeb.RoleControllerTest do
  use AuthWeb.ConnCase

  alias Auth.Role

  @create_attrs %{desc: "some desc", name: "some name", app_id: 1}
  @update_attrs %{desc: "some updated desc", name: "some updated name"}
  @invalid_attrs %{desc: nil, name: nil}

  def fixture(:role) do
    {:ok, role} = Role.create_role(@create_attrs)
    role
  end

  describe "index" do
    test "lists all roles", %{conn: conn} do
      conn = admin_login(conn)
      conn = get(conn, Routes.role_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Roles"
    end
  end

  describe "new role" do
    test "renders form", %{conn: conn} do
      conn = admin_login(conn)
      conn = get(conn, Routes.role_path(conn, :new))
      assert html_response(conn, 200) =~ "New Role"
    end
  end

  describe "create role" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = admin_login(conn)
      conn = post(conn, Routes.role_path(conn, :create), role: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.role_path(conn, :show, id)

      conn = get(conn, Routes.role_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Role"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = admin_login(conn)
      conn = post(conn, Routes.role_path(conn, :create), role: @invalid_attrs)

      assert html_response(conn, 200) =~ "New Role"
    end
  end

  describe "edit role" do
    setup [:create_role]

    test "renders form for editing chosen role", %{conn: conn, role: role} do
      conn = admin_login(conn)
      conn = get(conn, Routes.role_path(conn, :edit, role))

      assert html_response(conn, 200) =~ "Edit Role"
    end
  end

  describe "update role" do
    setup [:create_role]

    test "redirects when data is valid", %{conn: conn, role: role} do
      conn = admin_login(conn)
      conn = put(conn, Routes.role_path(conn, :update, role), role: @update_attrs)

      assert redirected_to(conn) == Routes.role_path(conn, :show, role)

      conn = get(conn, Routes.role_path(conn, :show, role))
      assert html_response(conn, 200) =~ "some updated desc"
    end

    test "renders errors when data is invalid", %{conn: conn, role: role} do
      conn = admin_login(conn)
      conn = put(conn, Routes.role_path(conn, :update, role), role: @invalid_attrs)

      assert html_response(conn, 200) =~ "Edit Role"
    end
  end

  describe "delete role" do
    setup [:create_role]

    test "deletes chosen role", %{conn: conn, role: role} do
      conn = admin_login(conn)
      conn = delete(conn, Routes.role_path(conn, :delete, role))

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

  test "POST /roles/grant without admin should 401", %{conn: conn} do
    alex = %{email: "alex_grant_role_fail@gmail.com", auth_provider: "email"}
    grantee = Auth.Person.create_person(alex)
    conn = assign(conn, :person, grantee)
    conn = AuthWeb.RoleController.grant(conn, %{"role_id" => 5, "person_id" => grantee.id})
    assert conn.status == 401
  end

  test "POST /roles/grant should create people_roles entry", %{conn: conn} do
    alex = %{email: "alex_grant_success@gmail.com", auth_provider: "email"}
    grantee = Auth.Person.create_person(alex)

    conn = admin_login(conn)
    conn = get(conn, Routes.role_path(conn, :grant, %{"role_id" => 5, "person_id" => grantee.id}))

    # the grant/2 controller handler redirects back to /person/:id
    assert html_response(conn, 302) =~ "redirected"

    # check that the record was created:
    pr = Auth.PeopleRoles.get_record(grantee.id, 5)
    assert pr.person_id == grantee.id
    assert pr.role_id == 5
    assert pr.granter_id == 1
  end

  test "GET /roles/revoke/:people_roles_id displays confirm prompt", %{conn: conn} do
    conn = admin_login(conn)
    conn = get(conn, Routes.role_path(conn, :revoke, 1))
    assert html_response(conn, 200) =~ "superadmin"
  end

  test "POST /roles/revoke/:people_roles_id revokes the role", %{conn: conn} do
    conn = admin_login(conn)
    conn = post(conn, Routes.role_path(conn, :revoke, 1))
    assert html_response(conn, 302) =~ "redirected"

    pr = Auth.PeopleRoles.get_by_id(1)
    assert pr.revoker_id == 1
  end

  test "AuthWeb.RoleController.revoke/2 unauthorized if not admin", %{conn: conn} do
    wrong_person_data = %{
      email: "unauthorized@gmail.com",
      auth_provider: "email",
      id: 42
    }

    Auth.Person.create_person(wrong_person_data)
    conn = AuthPlug.create_jwt_session(conn, wrong_person_data)

    conn = AuthWeb.RoleController.revoke(conn, %{"people_roles_id" => 1})
    assert conn.status == 401
  end
end
