defmodule AuthWeb.GithubAuthControllerTest do
  use AuthWeb.ConnCase

  test "index/2 handler for google auth callback", %{conn: conn} do

    conn = get(conn, Routes.github_auth_path(conn, :index,
      %{code: "123", state: "http://localhost/"}))
    assert html_response(conn, 302) =~ "http://localhost"  
  end
end
