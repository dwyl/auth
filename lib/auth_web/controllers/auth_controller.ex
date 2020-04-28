defmodule AuthWeb.AuthController do
  use AuthWeb, :controller
  alias Auth.Person

  @doc """
  `github_auth/2` handles the callback from GitHub Auth API redirect.
  """
  def github_handler(conn, %{"code" => code, "state" => state}) do
    {:ok, profile} = ElixirAuthGithub.github_auth(code)
    IO.inspect(profile, label: "github profile")
    # save profile to people:
    person = Person.create_github_person(profile)
    IO.inspect(person, label: "github profile > person")
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


  # def email_password_handler(conn, params) do
  #
  #   # GOTO: https://toranbillups.com/blog/archive/2018/11/18/implementing-basic-authentication/
  # end


  @doc """
  `handler/3` responds to successful auth requests.
  if the state is defined, redirect to it.
  """
  def handler(conn, person, state) do
    IO.inspect(person, label: "handler/3 > person")
    # Send welcome email:
    # Auth.Email.sendemail(%{
    #   email: person.email,
    #   name: person.givenName,
    #   template: "welcome"
    # })
    # |> IO.inspect(label: "email")

    IO.inspect(state, label: "state handler/3:53")

    # check if valid state (HTTP referer) is defined:
    case not is_nil(state) do
      true -> # redirect
        conn
        |> redirect(external: add_jwt_url_param(person, state))

      false -> # display welcome page
        conn
        |> put_view(AuthWeb.PageView)
        # |> AuthPlug.create_jwt_session(person)
        |> render(:welcome, person: person)
    end
  end

  def add_jwt_url_param(person, state) do
    data = %{
      auth_provider: person.auth_provider,
      givenName: person.givenName,
      id: person.id,
      picture: person.picture,
      status: person.status
    }

    jwt = AuthPlug.Token.generate_jwt!(data)
    URI.decode(state) <> "?jwt=" <> jwt
  end
end
