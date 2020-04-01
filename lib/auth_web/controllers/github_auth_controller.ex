defmodule AuthWeb.GithubAuthController do
  use AuthWeb, :controller

  @doc """
  `index/2` handles the callback from GitHub Auth API redirect.
  """
  def index(conn, %{"code" => code}) do
    {:ok, profile} = ElixirAuthGithub.github_auth(code)
    conn
    |> put_view(AuthWeb.PageView)
    |> render(:welcome_github, profile: profile)
  end
end
