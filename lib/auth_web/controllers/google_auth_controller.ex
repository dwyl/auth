defmodule AuthWeb.GoogleAuthController do
  use AuthWeb, :controller

  @doc """
  `index/2` handles the callback from Google Auth API redirect.
  """
  def index(conn, %{"code" => code}) do
    env = Mix.env()
    IO.inspect(env, label: "auth env")
    IO.inspect(System.get_env("MIX_ENV"), label: "MIX_ENV:10")
    {:ok, token} = ElixirAuthGoogle.get_token(code, conn)
    IO.inspect(token, label: "token")
    {:ok, profile} = ElixirAuthGoogle.get_user_profile(token.access_token)
    conn
    |> put_view(AuthWeb.PageView)
    |> render(:welcome_google, profile: profile)
  end
end
