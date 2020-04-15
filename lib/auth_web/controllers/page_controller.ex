defmodule AuthWeb.PageController do
  use AuthWeb, :controller

  def index(conn, _params) do
    state = get_referer(conn)
    oauth_github_url = ElixirAuthGithub.login_url(%{scopes: ["user:email"], state: state})
    oauth_google_url = ElixirAuthGoogle.generate_oauth_url(conn, state)

    render(conn, "index.html",
      oauth_github_url: oauth_github_url,
      oauth_google_url: oauth_google_url
    )
  end

  # https://github.com/dwyl/auth/issues/46
  def admin(conn, params) do
    IO.inspect(conn.req_headers, label: "conn.req_headers")
    IO.inspect(params, label: "params")

    conn
    |> put_view(AuthWeb.PageView)
    |> render(:admin)
  end

  defp get_referer(conn) do
    IO.inspect(conn)
    # https://stackoverflow.com/questions/37176911/get-http-referrer
    case List.keyfind(conn.req_headers, "referer", 0) do
      {"referer", referer} ->
        IO.inspect(referer, label: "referer")
        referer

      nil ->
        IO.puts("no referer")

        ElixirAuthGoogle.get_baseurl_from_conn(conn)
        |> IO.inspect(label: "baseurl")
    end
  end
end
