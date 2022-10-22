defmodule AuthWeb.GroupsLiveTest do
  use AuthWeb.ConnCase
  import Phoenix.LiveViewTest
  # alias Phoenix.Socket.Broadcast

  test "disconnected and connected render", %{conn: conn} do
    conn = non_admin_login(conn)
    {:ok, page_live, disconnected_html} = live(conn, "/groups")
    assert disconnected_html =~ "Groups"
    assert render(page_live) =~ "Groups"
  end
end
