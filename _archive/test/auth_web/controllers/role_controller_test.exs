defmodule AuthWeb.RoleControllerTest do
  use AuthWeb.ConnCase, async: true

  alias Auth.Role

  @create_attrs %{desc: "some desc", name: "some name", app_id: "1", person_id: 1}
  @update_attrs %{desc: "some updated desc", name: "some updated name"}
  @invalid_attrs %{desc: nil, name: nil}

  def fixture(:role) do
    {:ok, role} = Role.create_role(@create_attrs)
    role
  end

  describe "index" do
    test "lists all roles", %{conn: conn} do
      conn = admin_login(conn)
      # create a new role to exercise the RoleView.app_link/1 fn:
      attrs = Map.merge(@create_attrs, %{person_id: conn.assigns.person.id})
      {:ok, _role} = Auth.Role.create_role(attrs)

      conn = get(conn, Routes.role_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Roles"
    end

    test "non-admin can see all system and owned roles", %{conn: conn} do
      conn = non_admin_login(conn)
      conn = post(conn, Routes.role_path(conn, :create), role: @create_attrs)
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

    test "attempt to /roles/new without App redirects to /apps/new", %{conn: conn} do
      conn = non_admin_login(conn)
      conn = get(conn, Routes.role_path(conn, :new))
      assert html_response(conn, 302) =~ "redirected"
    end

    test "non-admin person create role", %{conn: conn} do
      conn = non_admin_login(conn)

      {:ok, _app} =
        Auth.App.create_app(%{
          "name" => "default system app",
          "desc" => "Demo App",
          "url" => "localhost:4000",
          "person_id" => conn.assigns.person.id,
          "status" => 3
        })

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
      assert html_response(conn, 200) =~ @create_attrs.name
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = admin_login(conn)
      conn = post(conn, Routes.role_path(conn, :create), role: @invalid_attrs)

      assert html_response(conn, 404) =~ "New Role"
    end

    test "renders errors when data is invalid (with app_id)", %{conn: conn} do
      conn = admin_login(conn)
      # invalid but with app_id:
      invalid = Map.merge(@invalid_attrs, %{"app_id" => "1"})
      conn = post(conn, Routes.role_path(conn, :create), role: invalid)

      assert html_response(conn, 200) =~ "New Role"
    end

    test "attempt to create role for app they don't own.", %{conn: conn} do
      conn = non_admin_login(conn)
      conn = post(conn, Routes.role_path(conn, :create), role: @create_attrs)

      assert html_response(conn, 404) =~ "Please select an app you own"
    end

    test "cannot create new role with name of existing role", %{conn: conn} do
      # see: https://github.com/dwyl/auth/issues/118
      conn = admin_login(conn)

      existing_role = %{
        name: "superadmin",
        desc: "this will fail because we don't allow duplicate roles",
        person_id: 1,
        app_id: 1
      }

      conn = post(conn, Routes.role_path(conn, :create), role: existing_role)
      assert html_response(conn, 200) =~ "Sorry, role name cannot be superadmin"
    end
  end

  describe "edit role" do
    setup [:create_role]

    test "renders form for editing chosen role", %{conn: conn, role: role} do
      conn = admin_login(conn)
      conn = get(conn, Routes.role_path(conn, :edit, role))

      assert html_response(conn, 200) =~ "Edit Role"
    end

    test "attempt to edit a role I don't own", %{conn: conn, role: role} do
      conn = non_admin_login(conn)
      conn = get(conn, Routes.role_path(conn, :edit, role))

      assert html_response(conn, 404) =~ "role not found"
    end
  end

  describe "update role" do
    setup [:create_role]

    test "redirects when data is valid", %{conn: conn} do
      conn = admin_login(conn)

      attrs =
        Map.merge(
          @create_attrs,
          %{person_id: conn.assigns.person.id, name: "myrole138"}
        )

      {:ok, role} = Auth.Role.create_role(attrs)
      update_attrs = Map.merge(@update_attrs, %{app_id: 1, role_id: role.id})
      conn = put(conn, Routes.role_path(conn, :update, role), role: update_attrs)

      assert redirected_to(conn) == Routes.role_path(conn, :show, role)

      conn = get(conn, Routes.role_path(conn, :show, role))
      assert html_response(conn, 200) =~ "some updated desc"
    end

    test "renders errors when data is invalid", %{conn: conn, role: role} do
      conn = admin_login(conn)
      invalid_app_id = Map.merge(@invalid_attrs, %{"app_id" => "1"})
      conn = put(conn, Routes.role_path(conn, :update, role), role: invalid_app_id)

      assert html_response(conn, 200) =~ "Edit Role"
    end

    test "cannot update role I don't own", %{conn: conn, role: role} do
      conn = non_admin_login(conn)
      conn = put(conn, Routes.role_path(conn, :update, role), role: @update_attrs)

      assert html_response(conn, 404) =~ "role not found"
    end

    test "cannot update role I own to App I don't own!", %{conn: conn} do
      conn = non_admin_login(conn)

      attrs = %{
        name: "myrole169",
        desc: "this fails",
        person_id: conn.assigns.person.id
      }

      {:ok, role} = Auth.Role.create_role(attrs)
      # attempt to update app_id to app owned by admin:
      update_attrs = Map.merge(role, %{app_id: 1})
      conn = put(conn, Routes.role_path(conn, :update, role), role: update_attrs)

      assert html_response(conn, 404) =~ "App not found"
    end
  end

  describe "delete role" do
    setup [:create_role]

    test "deletes chosen role", %{conn: conn, role: role} do
      conn = admin_login(conn)
      conn = delete(conn, Routes.role_path(conn, :delete, role))

      assert redirected_to(conn) == Routes.role_path(conn, :index)

      conn = get(conn, Routes.role_path(conn, :show, role))
      assert conn.status == 404
    end

    test "attempt to deletes role I don't own", %{conn: conn, role: role} do
      conn = non_admin_login(conn)
      conn = delete(conn, Routes.role_path(conn, :delete, role))
      assert conn.status == 404
    end
  end

  defp create_role(_) do
    role = fixture(:role)
    %{role: role}
  end

  test "non-admin person can grant default role on app they own", %{conn: conn} do
    # login as non-admin person
    conn = non_admin_login(conn)
    # create app:
    {:ok, app} =
      Auth.App.create_app(%{
        "name" => "My Test App",
        "desc" => "Demo App",
        "url" => "localhost:4000",
        "person_id" => conn.assigns.person.id,
        "status" => 3
      })

    # create role for app:
    attrs =
      Map.merge(
        @create_attrs,
        %{person_id: conn.assigns.person.id, app_id: app.id}
      )

    {:ok, role} = Auth.Role.create_role(attrs)

    # create *different* non-admin person:
    grantee = non_admin_person()

    #  attempt to grant a role for an app they don't own (should fail):
    conn =
      AuthWeb.RoleController.grant(
        conn,
        %{"role_id" => role.id, "person_id" => grantee.id, "app_id" => app.id}
      )

    # confirm redirected to the grantee's person
    assert html_response(conn, 302) =~ "people/#{grantee.id}"
  end

  test "Attempt to POST /roles/grant (non-owner of app) should 401", %{conn: conn} do
    grantee = non_admin_person()
    # login as *different* non-admin person
    conn = non_admin_login(conn)
    #  attempt to grant a role for an app they don't own (should fail):
    conn =
      post(
        conn,
        Routes.role_path(conn, :grant, %{
          "role_id" => 5,
          "person_id" => grantee.id,
          "app_id" => "1"
        })
      )

    assert conn.status == 401
  end

  test "POST /roles/grant should create people_roles entry", %{conn: conn} do
    grantee = non_admin_person()
    conn = admin_login(conn)

    conn =
      get(
        conn,
        Routes.role_path(conn, :grant, %{
          "role_id" => 5,
          "person_id" => grantee.id,
          "app_id" => "1"
        })
      )

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
    Auth.PeopleRoles.upsert(1, 1, 1, 1)
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

    conn =
      conn
      |> AuthPlug.create_jwt_session(wrong_person_data)
      # |> AuthWeb.RoleController.revoke(%{"people_roles_id" => 1})
      |> post(Routes.role_path(conn, :revoke, 1))

    assert conn.status == 401
  end
end
