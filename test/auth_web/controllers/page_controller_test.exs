defmodule AuthWeb.PageControllerTest do
  use AuthWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Authentication"
  end
end
