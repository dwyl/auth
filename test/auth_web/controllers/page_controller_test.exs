defmodule AuthWeb.PageControllerTest do
  use AuthWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "login to"
  end

  test "GET /admin", %{conn: conn} do
    conn = get(conn, "/admin")
    assert html_response(conn, 200) =~ "Login"
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
end
