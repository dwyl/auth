defmodule Auth.LogTest do
  use AuthWeb.ConnCase, async: true
  alias Auth.UserAgent
  require Logger

  test "E2E Test Auth.Log.error/2 inserts error log into db", %{conn: conn} do
    {:ok, role} = Auth.Role.create_role(%{name: "test", desc: "test", app_id: 1})

    conn =
      conn
      |> non_admin_login()
      |> put_req_header("content-type", "text/html")
      |> Auth.UserAgent.assign_ua()
      |> get(Routes.role_path(conn, :edit, role))

    assert conn.status == 404

    ua = UserAgent.upsert(conn)
    ua_string = UserAgent.make_ua_string(ua)

    assert conn.assigns.ua == ua_string

    log = List.last(Auth.Log.get_all())
    assert log.status_id == 404
  end

  test "Auth.Log.info/2 inserts an info log", %{conn: conn} do
    conn = non_admin_login(conn)
    rand = :rand.uniform(1_000_000)
    msg = "great success #{rand}"
    # insert log entry:
    Auth.Log.info(conn, %{status_id: 200, msg: msg})
    # retrieve log entry:
    log = List.first(Auth.Log.get_all())
    #  confirm what we expect:
    assert log.status_id == 200
    assert log.msg == msg
    assert log.person_id == conn.assigns.person.id
  end

  test "Auth.Log.error/2 inserts unauthenticated data", %{conn: conn} do
    person = non_admin_person()

    app_data = %{
      desc: "appdesc",
      name: "appname",
      url: "appurl",
      status: 3,
      person_id: person.id
    }

    {:ok, app} = Auth.App.create_app(app_data)
    rand = :rand.uniform(1_000_000)
    msg = "Don't Panic #{rand} (this is expected...)"
    email = "fail@mail.co"
    # insert log entry:
    Auth.Log.error(conn, %{
      status_id: 401,
      msg: msg,
      email: email,
      app_id: app.id,
      person_id: person.id,
      auth_provider: "email"
    })

    # retrieve log entry:
    log = List.first(Auth.Log.get_all())
    #  confirm what we expect:
    assert log.status_id == 401
    assert log.msg == msg
    assert log.email == email
    assert log.app_id == app.id
    assert log.auth_provider == "email"
  end
end
