defmodule AuthWeb.GoogleAuthControllerTest do
  use AuthWeb.ConnCase

  test "index/2 handler for google auth callback", %{conn: conn} do

    conn = get(conn, Routes.google_auth_path(conn, :index,
      %{code: "234", state: "http://localhost/"}))
    assert html_response(conn, 200) =~ "nelson@gmail.com"
  end
end
