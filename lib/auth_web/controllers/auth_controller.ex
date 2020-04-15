defmodule AuthWeb.AuthController do
  use AuthWeb, :controller
  alias Auth.Person

  @doc """
  `github_auth/2` handles the callback from GitHub Auth API redirect.
  """
  def github_handler(conn, %{"code" => code, "state" => state}) do
    {:ok, profile} = ElixirAuthGithub.github_auth(code)
    person = Person.transform_github_profile_data_to_person(profile)
      |> Person.create_person()
    # render or redirect:
    handler(conn, person, state)
  end

  @doc """
  `google_handler/2` handles the callback from Google Auth API redirect.
  """
  def google_handler(conn, %{"code" => code, "state" => state}) do
    {:ok, token} = ElixirAuthGoogle.get_token(code, conn)
    {:ok, profile} = ElixirAuthGoogle.get_user_profile(token.access_token)
    # save profile to people:
    person = Auth.Person.create_google_person(profile)
    # render or redirect:
    handler(conn, person, state)
  end


  @doc """
  `handler/3` responds to successful auth requests.
  if the state is defined, redirect to it.
  """
  def handler(conn, person, state) do
    case not is_nil(state) and state =~ "//" do
      true -> # redirect
        url = state <> "?jwt=this.is.amaze"
        conn
        # |> put_req_header("authorization", "MY.JWT.HERE")
        |> redirect(external: url)
        # |> halt()
      false -> # no state
        conn
        |> put_view(AuthWeb.PageView)
        |> render(:welcome, person: person)
    end
  end

  def redirect_to_referer_with_jwt(conn, referer, person) do
    IO.inspect(conn, label: "conn")
    IO.inspect(referer, label: "referer")
    IO.inspect(person, label: "person")
  end
end
