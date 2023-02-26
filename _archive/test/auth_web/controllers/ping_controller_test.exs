defmodule AuthWeb.PingControllerTest do
  use AuthWeb.ConnCase, async: true

  test "GET /ping (GIF) renders 1x1 pixel", %{conn: conn} do
    conn = get(conn, Routes.ping_path(conn, :ping))
    assert conn.status == 200
    assert conn.state == :sent
    assert conn.resp_body =~ <<71, 73, 70, 56, 57>>
  end
end
