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
  def admin(conn, _params) do
    conn
    |> put_view(AuthWeb.PageView)
    |> render(:welcome)
  end

  def append_client_id(ref, client_id) do
    ref <> "?auth_client_id=" <> client_id
  end

  def get_referer(conn) do
    # https://stackoverflow.com/questions/37176911/get-http-referrer
    case List.keyfind(conn.req_headers, "referer", 0) do
      {"referer", referer} ->
        referer

      nil -> # referer not in headers, check URL query:
        case conn.query_string =~ "referer" do
          true ->
            query = URI.decode_query(conn.query_string)
            ref = Map.get(query, "referer")
            client_id = get_client_id_from_query(conn)
            ref |> URI.encode |> append_client_id(client_id)

          false -> # no referer, redirect back to Auth app.
            AuthPlug.Helpers.get_baseurl_from_conn(conn) <> "/profile"
            |> URI.encode
            |> append_client_id(AuthPlug.Token.client_id())
        end
    end
  end

  def get_client_id_from_query(conn) do
    case conn.query_string =~ "auth_client_id" do
      true ->
        Map.get(URI.decode_query(conn.query_string), "auth_client_id")
      false -> # no client_id, redirect back to this app.
        0
    end
  end
end
