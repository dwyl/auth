defmodule AuthWeb.PageController do
  use AuthWeb, :controller

  def index(conn, _params) do
    get_referer(conn)
    oauth_github_url =
      ElixirAuthGithub.login_url(%{scopes: ["user:email"]})
    oauth_google_url = ElixirAuthGoogle.generate_oauth_url(conn)
    render(conn, "index.html", [
      oauth_github_url: oauth_github_url,
      oauth_google_url: oauth_google_url
    ])
  end


  def get_referer(conn) do
    # IO.inspect(conn, label: "extact_referer/1:16 conn")
    # https://stackoverflow.com/questions/37176911/get-http-referrer
    case List.keyfind(conn.req_headers, "referer", 0) do
      {"referer", referer} ->
        IO.puts referer
      nil ->
        IO.puts "no referer"
    end
    conn
  end

end
