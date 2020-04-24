defmodule AuthWeb.AuthControllerTest do
  use AuthWeb.ConnCase

  test "github_handler/2 github auth callback", %{conn: conn} do
    conn = get(conn, "/auth/github/callback",
      %{code: "123", state: "http://localhost/"})
    # assert html_response(conn, 200) =~ "test@gmail.com"
    assert html_response(conn, 302) =~ "http://localhost"
  end

  test "google_handler/2 for google auth callback", %{conn: conn} do
    conn = get(conn, "/auth/google/callback",
      %{code: "234", state: "http://localhost/"})

    # assert html_response(conn, 200) =~ "nelson@gmail.com"
    assert html_response(conn, 302) =~ "http://localhost"
  end

  test "google_handler/2 show welcome page", %{conn: conn} do
    conn = get(conn, "/auth/google/callback",
      %{code: "234", state: AuthPlug.Helpers.get_baseurl_from_conn(conn)})

    assert html_response(conn, 200) =~ "nelson@gmail.com"
    # assert html_response(conn, 302) =~ "redirected"
  end
end
