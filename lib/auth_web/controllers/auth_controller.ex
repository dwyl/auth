defmodule AuthWeb.AuthController do
  use AuthWeb, :controller
  alias Auth.Person

  @doc """
  `github_auth/2` handles the callback from GitHub Auth API redirect.
  """
  def github_handler(conn, %{"code" => code, "state" => state}) do
    {:ok, profile} = ElixirAuthGithub.github_auth(code)
    # save profile to people:
    person = Person.create_github_person(profile)
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
    person = Person.create_google_person(profile)
    # render or redirect:
    handler(conn, person, state)
  end

  @doc """
  `handler/3` responds to successful auth requests.
  if the state is defined, redirect to it.
  """
  def handler(conn, person, state) do
    case not is_nil(state) and state =~ "//" do
      # redirect
      true ->
        url = add_jwt_url_param(person, state)

        conn
        # |> put_req_header("authorization", "MY.JWT.HERE")
        |> redirect(external: url)

      # |> halt()
      # no state
      false ->
        conn
        |> put_view(AuthWeb.PageView)
        |> render(:welcome, person: person)
    end
  end

  def add_jwt_url_param(person, state) do
    IO.inspect(state, label: "state")
    IO.inspect(person, label: "person")
    data = %{
      auth_provider: person.auth_provider,
      givenName: person.givenName,
      id: person.id,
      picture: person.picture,
      status: person.status,
    }
    jwt = Auth.Token.generate_and_sign!(data)
    |> IO.inspect(label: "jwt")
    state <> "?jwt=" <> jwt
  end
end
