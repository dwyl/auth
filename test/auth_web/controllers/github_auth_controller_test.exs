defmodule AuthWeb.GithubAuthControllerTest do
  use AuthWeb.ConnCase

  test "index/2 handler for google auth callback", %{conn: conn} do

    conn = get(conn, Routes.github_auth_path(conn, :index,
      %{code: "123", state: "http://localhost/"}))
    # IO.inspect(conn, label: "conn")

    assert html_response(conn, 200) =~ "test@gmail.com"

    # # same again to exercise to the branch where person already exists:
    # conn = get(conn, Routes.google_auth_path(conn, :index, %{code: "234", state: "http://localhost/"}))
    # assert html_response(conn, 302)
  end
end
