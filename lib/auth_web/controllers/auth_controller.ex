defmodule AuthWeb.AuthController do
  use AuthWeb, :controller
  alias Auth.Person

  # https://github.com/dwyl/auth/issues/46
  def admin(conn, _params) do
    conn
    |> render(:welcome)
  end

  def index(conn, params) do
    params_person = Map.get(params, "person")
    email = if not is_nil(params_person)
      and not is_nil(Map.get(params_person, "email")) do
        Map.get(Map.get(params, "person"), "email")
    else
      nil
    end

    # TODO: add friendly error message when email is invalid
    # IO.inspect(Fields.Validate.email(email), label: "Fields.Validate.email(email)")
    # errors = if not is_nil(email) and not Fields.Validate.email(email) do
    #   [email: "email address is invalid"]
    # else
    #   []
    # end
    #
    # IO.inspect(email, label: "email")
    # IO.inspect(errors, label: "errors")


    state = if not is_nil(params_person)
      and not is_nil(Map.get(params_person, "state")) do
        Map.get(params_person, "state")
    else
      get_referer(conn) # get from headers
    end


    oauth_github_url = ElixirAuthGithub.login_url(%{scopes: ["user:email"],
      state: state})
    oauth_google_url = ElixirAuthGoogle.generate_oauth_url(conn, state)

    conn
    |> assign(:action, Routes.auth_path(conn, :login_register_handler))
    |> render("index.html",
      oauth_github_url: oauth_github_url,
      oauth_google_url: oauth_google_url,
      changeset: Auth.Person.login_register_changeset(%{email: email}),
      state: state,
      # errors: errors
    )
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
    IO.inspect(conn.query_string, label: "conn.query_string")
    case conn.query_string =~ "auth_client_id" do
      true ->
        Map.get(URI.decode_query(conn.query_string), "auth_client_id")
      false -> # no client_id, redirect back to this app.
        0
    end
  end

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
    # IO.inspect(state, label: "state:22")
    {:ok, token} = ElixirAuthGoogle.get_token(code, conn)
    {:ok, profile} = ElixirAuthGoogle.get_user_profile(token.access_token)

    # save profile to people:
    person = Person.create_google_person(profile)

    # render or redirect:
    handler(conn, person, state)
  end


  @doc """
  `login_register_handler/2` is a hybrid of traditional registration and login.
  If the person has already registered, we treat it as a login attempt and
  present them with a password field/form to complete.
  If the person does *not* exist (or has not yet verified their email address),
  we show them a welcome screen informing them that a verification email
  was sent to their address. When they click it they will see a password (reset)
  form where they can define a new password for their account.
  """
  def login_register_handler(conn, params) do
    IO.inspect(params, label: "params:130")
    params_person = Map.get(params, "person")
    email = Map.get(params_person, "email")
    state = Map.get(params_person, "state")
    IO.inspect(email, label: "email")
    # email is blank or invalid:
    if is_nil(email) or not Fields.Validate.email(email) do
      conn # email invalid, re-render the login/register form:
      |> index(params)
    else
      IO.puts("email is NOT nil: " <>  email)
      person = Auth.Person.get_person_by_email(email)
      # IO.inspect(person, label: "person:142")
      # check if the email exists in the people table:
      person = if is_nil(person) do
        person = Auth.Person.create_person(%{
          email: email,
          auth_provider: "email"
        })
        # IO.inspect(person, label: "person:146")
        Auth.Email.sendemail(%{ email: email, template: "verify",
          link: make_verify_link(conn, person, state),
          subject: "Please Verify Your Email Address"
        })

        person
      else
        person
      end
      # IO.inspect(person, label: "person:156")
      if not is_nil(person.status) and person.status == 1 do # verified
        conn
        |> assign(:action, Routes.auth_path(conn, :login_register_handler))
        |> render("password-prompt.html",
          changeset: Auth.Person.password_prompt_changeset(%{email: email}),
          state: state,
          person_id: AuthWeb.ApikeyController.encrypt_encode(person.id) # hide
        )
      else
        # respond
        conn
        |> put_resp_content_type("text/html")
        |> send_resp(200, "login_register_handler " <> email)
        |> halt()
      end
    end
  end

  def make_verify_link(conn, person, state) do
    AuthPlug.Helpers.get_baseurl_from_conn(conn)
    <> "/auth/verify?id="
    <> AuthWeb.ApikeyController.encrypt_encode(person.id)
    <> "&referer=" <> state
  end

  def verify_email(conn, params) do
    IO.inspect(params, label: "params:186")
    referer = params["referer"]
    IO.inspect(referer, label: "referer:188")
    person_id = AuthWeb.ApikeyController.decode_decrypt(params["id"])
    IO.inspect(person_id, label: "person_id:190")
    person = Auth.Person.verify_person_by_id(person_id)

    client_secret = get_client_secret_from_state(referer)
    IO.inspect(client_secret, label: "client_secret:193")
    # ref = get_referer(conn)
    # IO.inspect(ref, label: "referer:188")

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, "verify_email")
    |> halt()
  end


  # def email_handler(conn, params) do
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
            # |> AuthPlug.create_session(person, secret)
            |> redirect(external: add_jwt_url_param(person, state, secret))
        end

      false -> # display welcome page on Auth site:
        conn
        |> AuthPlug.create_jwt_session(person)
        |> render(:welcome, person: person)
    end
  end

  def unauthorized(conn) do
    # IO.inspect(conn)
    conn
    # |> put_resp_header("www-authenticate", "Bearer realm=\"Person access\"")
    |> put_resp_content_type("text/html")
    |> send_resp(401, "invalid AUTH_API_KEY/client_id please check.")
    |> halt()
  end

  # TODO: refactor this to render a template with a nice layout.
  def not_found(conn, message) do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(404, message)
    |> halt()
  end


  @doc """
  `get_client_secret_from_state/1` gets the client_id from state,
  attempts to decode_decrypt it and then look it up in apikeys
  if it finds the corresponding client_secret it returns the client_secret.
  All other failure conditions return a 0 (zero) which results in a 401.
  """
  def get_client_secret_from_state(state) do
    # IO.inspect(state, label: "state:94")
    # decoded = URI.decode(state)
    # IO.inspect(decoded, label: "decoded:96")
    query = URI.decode_query(List.last(String.split(state, "?")))
    # IO.inspect(query, label: "query:100")
    client_id = Map.get(query, "auth_client_id")
    # IO.inspect(client_id, label: "client_id")
    case not is_nil(client_id) do
      true -> # Lookup client_id in apikeys table
        get_client_secret(client_id, state)

      false -> # state without client_id is not valid
        0
    end
  end

  def get_client_secret(client_id, state) do
    person_id = AuthWeb.ApikeyController.decode_decrypt(client_id)
    # IO.inspect(person_id, label: "person_id:114")
    if person_id == 0 do # decode_decrypt fails with state 0
      # IO.inspect(person_id, label: "person_id:116")
      0
    else
      apikeys = Auth.Apikey.list_apikeys_for_person(person_id)
      # IO.inspect(apikeys, label: "apikeys:120")
      Enum.filter(apikeys, fn(k) ->
        k.client_id == client_id and state =~ k.url
      end) |> List.first() |> Map.get(:client_secret)

    end
  end



  def add_jwt_url_param(person, state, client_secret) do
    data = %{
      auth_provider: person.auth_provider,
      givenName: person.givenName,
      id: person.id,
      picture: person.picture,
      status: person.status
    }

    jwt = AuthPlug.Token.generate_jwt!(data, client_secret)
    List.first(String.split(URI.decode(state), "?"))
     <> "?jwt=" <> jwt
    # |> IO.inspect(label: "state+jwt:146")
  end
end
