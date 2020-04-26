defmodule AuthWeb.PageControllerTest do
  use AuthWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "login to"
  end

  test "GET /profile", %{conn: conn} do
    conn = get(conn, "/profile")
    # assert html_response(conn, 301) =~ "Login"
    assert conn.status == 302
  end

  test "get_referer/1", %{conn: conn} do
    conn = conn
      |> put_req_header("referer", "http://localhost/admin")
      |> get("/")

    assert conn.resp_body =~ "state=http://localhost/admin"
  end

  test "get_referer/1 query_string", %{conn: conn} do
    conn = conn
      |> get("/?referer=" <> URI.encode("http://localhost/admin"))

    assert conn.resp_body =~ "state=http://localhost/admin"
  end

  test "google_handler/2 show welcome (state=nil) > handler/3", %{conn: conn} do
    data = %{
      email: "nelson@gmail.com",
      givenName: "McTestin",
      picture: "https://youtu.be/naoknj1ebqI",
      auth_provider: "google"
    }
    person = Auth.Person.create_person(data) # |> IO.inspect(label: "person")
    conn = AuthPlug.create_jwt_session(conn, Map.merge(data, %{id: person.id}))
    conn = get(conn, "/auth/google/callback",
      %{code: "234", state: nil})

    assert html_response(conn, 200) =~ "google account"
    # assert html_response(conn, 302) =~ "redirected"
  end
end
