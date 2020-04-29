defmodule AuthWeb.AuthController do
  use AuthWeb, :controller
  alias Auth.Person

  @doc """
  `github_auth/2` handles the callback from GitHub Auth API redirect.
  """
  def github_handler(conn, %{"code" => code, "state" => state}) do
    {:ok, profile} = ElixirAuthGithub.github_auth(code)
    # IO.inspect(profile, label: "github profile")
    # save profile to people:
    person = Person.create_github_person(profile)
    # IO.inspect(person, label: "github profile > person")
    # render or redirect:
    handler(conn, person, state)
  end

  @doc """
  `google_handler/2` handles the callback from Google Auth API redirect.
  """
  def google_handler(conn, %{"code" => code, "state" => state}) do
    IO.inspect(state, label: "state:22")
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
    # IO.inspect(person, label: "handler/3 > person")
    # Send welcome email:
    Auth.Email.sendemail(%{
      email: person.email,
      name: person.givenName,
      template: "welcome"
    })
    # |> IO.inspect(label: "email")

    # IO.inspect(state, label: "state handler/3:53")

    # check if valid state (HTTP referer) is defined:
    case not is_nil(state) do
      true -> # redirect
        case get_client_secret_from_state(state) do
          0 ->
            # IO.inspect("client_secret is 0 (error)")
            unauthorized(conn)
          secret ->
            # IO.inspect(secret, label: "secret")
            conn
            |> redirect(external: add_jwt_url_param(person, state, secret))
        end

      false -> # display welcome page
        conn
        |> put_view(AuthWeb.PageView)
        |> AuthPlug.create_jwt_session(person)
        |> render(:welcome, person: person)
    end
  end

  defp unauthorized(conn) do
    # IO.inspect(conn)
    conn
    # |> put_resp_header("www-authenticate", "Bearer realm=\"Person access\"")
    |> put_resp_content_type("text/html")
    |> send_resp(401, "invalid AUTH_API_KEY/client_id please check.")
    |> halt()
  end


  @doc """
  `get_client_secret_from_state/1` gets the client_id from state,
  attempts to decode_decrypt it and then look it up in apikeys
  if it finds the corresponding client_secret it returns the client_secret.
  All other failure conditions return a 0 (zero) which results in a 401.
  """
  def get_client_secret_from_state(state) do
    IO.inspect(state, label: "state:94")
    query = URI.decode_query(state)
    IO.inspect(query, label: "query:96")
    client_id = Map.get(query, "auth_client_id")
    IO.inspect(client_id, label: "client_id")
    case not is_nil(client_id) do
      true -> # Lookup client_id in apikeys table
        get_client_secret(client_id, state)

      false -> # state without client_id is not valid
        0
    end
  end

  def get_client_secret(client_id, state) do
    person_id = AuthWeb.ApikeyController.decode_decrypt(client_id)
    # IO.inspect(person_id, label: "person_id")
    if person_id == 0 do # decode_decrypt fails with state 0
      # IO.inspect(person_id, label: "person_id:88")
      0
    else
      apikeys = Auth.Apikey.list_apikeys_for_person(person_id)
      # IO.inspect(apikeys)
      Enum.filter(apikeys, fn(k) ->
        k.client_id == client_id and state =~ k.url
      end) |> List.first() |> Map.get(:client_secret)

    end
  end



  def add_jwt_url_param(person, state, client_secret) do

    IO.inspect(state, label: "state")

    data = %{
      auth_provider: person.auth_provider,
      givenName: person.givenName,
      id: person.id,
      picture: person.picture,
      status: person.status
    }

    jwt = AuthPlug.Token.generate_jwt!(data, client_secret)
    URI.decode(state) <> "?jwt=" <> jwt
  end
end
