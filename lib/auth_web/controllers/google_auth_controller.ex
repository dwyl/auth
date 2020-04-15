defmodule AuthWeb.GoogleAuthController do
  use AuthWeb, :controller

  @doc """
  `index/2` handles the callback from Google Auth API redirect.
  """
  def index(conn, %{"code" => code}) do
    {:ok, token} = ElixirAuthGoogle.get_token(code, conn)
    {:ok, profile} = ElixirAuthGoogle.get_user_profile(token.access_token)

    # save profile to people:
    person = Auth.Person.create_google_person(profile)

    conn
    |> put_view(AuthWeb.PageView)
    |> render(:welcome, person: person)
  end
end
