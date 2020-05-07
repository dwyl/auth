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
      state: state
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
    IO.inspect(profile, label: "github profile:96")
    # save profile to people:
    person = Person.create_github_person(profile)
    IO.inspect(person, label: "github profile > person:99")
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
  `handler/3` responds to successful auth requests.
  if the state is defined, redirect to it.
  """
  def handler(conn, person, state) do
    # Send welcome email:
    Auth.Email.sendemail(%{
      email: person.email,
      name: person.givenName,
      template: "welcome"
    })
    redirect_or_render(conn, person, state)
  end

  def redirect_or_render(conn, person, state) do
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
  `login_register_handler/2` is a hybrid of traditional registration and login.
  If the person has already registered, we treat it as a login attempt and
  present them with a password field/form to complete.
  If the person does *not* exist (or has not yet verified their email address),
  we show them a welcome screen informing them that a verification email
  was sent to their address. When they click it they will see a password (reset)
  form where they can define a new password for their account.
  """
  def login_register_handler(conn, params) do
    # IO.inspect(params, label: "params:130")
    params_person = Map.get(params, "person")
    email = Map.get(params_person, "email")
    state = Map.get(params_person, "state")
    # IO.inspect(email, label: "email")
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

      cond do
        is_nil(person.status) and is_nil(person.password_hash) ->
          # person has not verified their email address or created a password
          message = """
          You registered with the email address: #{email}. An email was sent
          to you with a link to confirm your address. Please check your email
          inbox for our message, open it and click the link.
          """
          render_password_form(conn, email, message, state, "password_create")

        person.status > 0 and is_nil(person.password_hash) ->
          # has verified but not yet defined a password
          render_password_form(conn, email, "", state, "password_create")

        is_nil(person.status) and not is_nil(person.password_hash) ->
          # person has not yet verified their email but has defined a password
          message = """
          You registered with the email address: #{email}. An email was sent
          to you with a link to confirm your address. Please check your email
          inbox for our message, open it and click the link.
          You can still login using the password you saved.
          """
          render_password_form(conn, email, message, state, "password_prompt")

        person.status > 0 and not is_nil(person.password_hash) ->
          # render password prompt without any put_flash message
          render_password_form(conn, email, "", state, "password_prompt")

      end
    end
  end

  def render_password_form(conn, email, message, state, template) do
    conn
      |> put_flash(:info, message)
      |> assign(:action, Routes.auth_path(conn, :password_create))
      |> render(template <> ".html",
        changeset: Auth.Person.password_new_changeset(%{email: email}),
        state: state, # so we can redirect after creatig a password
        email: AuthWeb.ApikeyController.encrypt_encode(email)
      )
  end


  def make_verify_link(conn, person, state) do
    AuthPlug.Helpers.get_baseurl_from_conn(conn)
    <> "/auth/verify?id="
    <> AuthWeb.ApikeyController.encrypt_encode(person.id)
    <> "&referer=" <> state
  end

  def password_input(conn, params) do
    IO.inspect(params, label: "params:197")
    conn
    |> assign(:action, Routes.auth_path(conn, :password_create))
    |> render("password_create.html",
      changeset: Auth.Person.password_new_changeset(%{email: params["email"]}),
      state: params["state"], # so we can redirect after creatig a password
      email: AuthWeb.ApikeyController.encrypt_encode(params["email"])
    )
  end

  @doc """
  `password_create/2` is called when a new person is registering with email
  and is defining a password for the first time.
  Note: at present we are not enforcing any rules for password strength/length.
  Thinking of doing these checks as progressive enhancement in Browser.
  see:
  """
  def password_create(conn, params) do
    IO.inspect(params, label: "password_create > params:271")
    p = params["person"]
    email = Auth.Person.decrypt_email(p["email"])
    person = Auth.Person.upsert_person(%{email: email, password: p["password"]})
    redirect_or_render(conn, person, p["state"])
  end

  # def passwprd_prompt(conn, params) do
  #
  # end


  def password_verify(conn, params) do
    IO.inspect(params, label: "param")
    # respond
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, "password_verify")
    |> halt()

  end




  def verify_email(conn, params) do
    IO.inspect(params, label: "verify_email params:297")
    referer = params["referer"]
    id = AuthWeb.ApikeyController.decode_decrypt(params["id"])
    person = Auth.Person.verify_person_by_id(id)
    secret = get_client_secret_from_state(referer)
    conn
    |> redirect(external: add_jwt_url_param(person, referer, secret))
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
      status: person.status,
      email: person.email
    }

    jwt = AuthPlug.Token.generate_jwt!(data, client_secret)
    List.first(String.split(URI.decode(state), "?"))
     <> "?jwt=" <> jwt
    # |> IO.inspect(label: "state+jwt:146")
  end
end
