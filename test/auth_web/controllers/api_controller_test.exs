defmodule AuthWeb.ApiControllerTest do
  use AuthWeb.ConnCase, async: true
  alias Auth.App
  alias Auth.Role

  @create_attrs %{
    desc: "some description",
    end: ~N[2010-04-17 14:00:00],
    name: "some name",
    url: "some url",
    status: 3,
    person_id: 1
  }

  def fixture(:app) do
    {:ok, app} = App.create_app(@create_attrs)
    app
  end

  defp create_app(_) do
    app = fixture(:app)
    %{app: app}
  end

  describe "GET /approles/:client_id" do
    setup [:create_app]

    test "returns 401 if client_id is invalid", %{conn: conn} do
      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> get("/approles/invalid")

      assert conn.status == 401
      {:ok, json} = Jason.decode(conn.resp_body)
      assert json["msg"] == "invalid AUTH_API_KEY/client_id please check"
    end

    test "returns (JSON) list of roles", %{conn: conn, app: app} do
      roles = Auth.Role.list_roles_for_app(app.id)
      key = List.first(app.apikeys)

      conn =
        conn
        |> admin_login()
        |> put_req_header("accept", "application/json")
        |> get("/approles/#{key.client_id}")

      assert conn.status == 200
      {:ok, json} = Jason.decode(conn.resp_body)
      assert length(roles) == length(json)
    end

    test "returns only relevant roles", %{conn: conn, app: app} do
      roles = Role.list_roles_for_app(app.id)
      # admin create role:
      admin_role = %{desc: "admin role", name: "new admin role", app_id: app.id}
      {:ok, %Role{} = admin_role} = Role.create_role(admin_role)
      # check that the new role was added to the admin app role list:
      roles2 = Role.list_roles_for_app(app.id)
      assert length(roles) < length(roles2)
      last = List.last(roles2)
      assert last.name == admin_role.name

      # login as non-admin person
      conn2 = non_admin_login(conn)

      # create non-admin app (to get API Key)
      {:ok, non_admin_app} =
        Auth.App.create_app(%{
          "name" => "default system app",
          "desc" => "Demo App",
          "url" => "localhost:4000",
          "person_id" => conn2.assigns.person.id,
          "status" => 3
        })

      # create non-admin role:
      role_data = %{
        desc: "non-admin role",
        name: "non-admin role",
        app_id: non_admin_app.id
      }

      {:ok, %Role{} = role2} = Role.create_role(role_data)
      key = List.first(non_admin_app.apikeys)

      conn3 =
        conn2
        |> admin_login()
        |> put_req_header("accept", "application/json")
        |> get("/approles/#{key.client_id}")

      assert conn3.status == 200
      {:ok, json} = Jason.decode(conn3.resp_body)
      last_role = List.last(json)
      # confirm the last role in the list is the new non-admin role:
      assert Map.get(last_role, "name") == role2.name

      # confirm the admin_role is NOT in the JSON reponse:
      should_be_empty =
        Enum.filter(json, fn r ->
          Map.get(r, "name") == admin_role.name
        end)

      assert should_be_empty == []
    end
  end

  describe "GET /personroles/:person_id/:client_id" do
    setup [:create_app]

    test "returns 401 if client_id is invalid", %{conn: conn} do
      conn =
        conn
        |> put_req_header("accept", "application/json")
        |> get("/personroles/1/invalid")

      assert conn.status == 401
      {:ok, json} = Jason.decode(conn.resp_body)
      assert json["msg"] == "invalid AUTH_API_KEY/client_id please check"
    end

    test "returns (JSON) list of roles", %{conn: conn, app: app} do
      conn = admin_login(conn)
      # creat role for app:
      attrs = %{desc: "test role", name: "testrole110", app_id: "1", person_id: 1}
      {:ok, role} = Auth.Role.create_role(attrs)

      # grant the *new* role to the new person:
      grantee = non_admin_person()
      granter_id = 1
      Auth.PeopleRoles.insert(app.id, grantee.id, granter_id, role.id)

      # grant existing (default) "creator" role to new person:
      Auth.PeopleRoles.insert(app.id, grantee.id, granter_id, 4)

      # roles = Auth.Role.list_roles_for_app(app.id)
      key = List.first(app.apikeys)

      conn =
        conn
        |> put_req_header("accept", "application/json")
        |> get("/personroles/#{grantee.id}/#{key.client_id}")

      assert conn.status == 200
      {:ok, json} = Jason.decode(conn.resp_body)
      assert length(json) == 2
    end
  end

  test "GET /end_session (API)", %{conn: conn} do
    conn = conn |> admin_login()
    conn = conn |> Auth.Session.start_session(conn.assigns.person)
  
    client_id = AuthPlug.Token.client_id()
    session_id = conn.assigns.sid
    end_session_endpoint = "/end_session/#{client_id}/#{session_id}"

    conn_ended = conn
      |> put_req_header("accept", "application/json")
      |> get(end_session_endpoint)

    {:ok, json} = Jason.decode(conn_ended.resp_body)
    assert json == %{"message" => "session ended"}

    # confirm the session was ended:
    session = Auth.Session.get_by_id(conn)
    assert session.end == session.updated_at
  end

  test "attempt to GET /end_session (API) with invalid client_id", %{conn: conn} do
    conn = conn |> admin_login()
    conn = conn |> Auth.Session.start_session(conn.assigns.person)
  
    # attempt the request with an invalid client_id:
    client_id = "invalid.client_id"
    session_id = conn.assigns.sid
    end_session_endpoint = "/end_session/#{client_id}/#{session_id}"

    conn_failed = conn
      |> put_req_header("accept", "application/json")
      |> get(end_session_endpoint)

    # expect 401 + error msg:
    assert conn_failed.status == 401
    {:ok, json} = Jason.decode(conn_failed.resp_body)
    assert Map.get(json, "msg") == "invalid AUTH_API_KEY/client_id please check"

  end
end
