defmodule AuthWeb.PageController do
  use AuthWeb, :controller

  def index(conn, _params) do
    oauth_github_url = ElixirAuthGithub.login_url(%{scopes: ["user:email"]})
    render(conn, "index.html", [oauth_github_url: oauth_github_url])
  end
end
