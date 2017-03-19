defmodule Auth.PageController do
  use Auth.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
