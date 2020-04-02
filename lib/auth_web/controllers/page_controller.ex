defmodule AuthWeb.PageController do
  use AuthWeb, :controller

  @elixir_auth_google Application.get_env(:auth_mvp, :elixir_auth_google) || ElixirAuthGoogle
  @elixir_auth_github Application.get_env(:auth_mvp, :elixir_auth_github) || ElixirAuthGithub

  def index(conn, _params) do
    oauth_github_url = ElixirAuthGithub.login_url(%{scopes: ["user:email"]})
    oauth_google_url = ElixirAuthGoogle.generate_oauth_url(conn)
    render(conn, "index.html", [
      oauth_github_url: oauth_github_url,
      oauth_google_url: oauth_google_url
    ])
  end
end
