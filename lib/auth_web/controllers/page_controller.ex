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
    # IO.inspect(conn.req_headers, label: "conn.req_headers")
    IO.inspect(params, label: "params")

    conn
    |> put_view(AuthWeb.PageView)
    |> render(:admin)
  end

  def get_referer(conn) do
    # https://stackoverflow.com/questions/37176911/get-http-referrer
    case List.keyfind(conn.req_headers, "referer", 0) do
      {"referer", referer} ->
        referer
        |> IO.inspect(label: "req_headers referer")

      nil -> # referer not in headers, check URL query:
        case conn.query_string =~ "referer" do
          true ->
            query = URI.decode_query(conn.query_string)
            Map.get(query, "referer")
            |> IO.inspect(label: "url referer")

          false -> # no referer, redirect back to this app. TODO:
            IO.inspect("false: no referer")
            ElixirAuthGoogle.get_baseurl_from_conn(conn)
        end
    end
    |> URI.encode |> IO.inspect(label: "referer")
  end
end
