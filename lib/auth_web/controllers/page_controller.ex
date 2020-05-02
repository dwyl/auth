defmodule AuthWeb.PageController do
  use AuthWeb, :controller

  # https://github.com/dwyl/auth/issues/46
  def admin(conn, _params) do
    conn
    |> put_view(AuthWeb.PageView)
    |> render(:welcome)
  end
  
end
