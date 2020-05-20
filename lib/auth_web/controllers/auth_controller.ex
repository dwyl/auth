defmodule AuthWeb.AuthController do
  use AuthWeb, :controller
  alias Auth.Person

  # https://github.com/dwyl/auth/issues/46
  def admin(conn, _params) do
    conn
    |> render(:welcome)
  end

  defp get_user_agent_string(conn) do
    user_agent_header =
      Enum.filter(conn.req_headers, fn {k, _} ->
        k == "user-agent"
      end)

    case user_agent_header do
      [{_, ua}] -> ua
      _ -> "undefined_user_agent"
    end
  end

  defp get_ip_address(conn) do
    Enum.join(Tuple.to_list(conn.remote_ip), ".")
  end

  def index(conn, params) do
    params_person = Map.get(params, "person")

    email =
      if not is_nil(params_person) and
           not is_nil(Map.get(params_person, "email")) do
        Map.get(Map.get(params, "person"), "email")
      else
        nil
      end

    # TODO: add friendly error message when email address is invalid
    # errors = if not is_nil(email) and not Fields.Validate.email(email) do
    #   [email: "email address is invalid"]
    # else
    #   []
    # end

    state =
      if not is_nil(params_person) and
           not is_nil(Map.get(params_person, "state")) do
        Map.get(params_person, "state")
      else
        # get from headers
        get_referer(conn)
      end

    oauth_github_url = ElixirAuthGithub.login_url(%{scopes: ["user:email"], state: state})
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

      #  referer not in headers, check URL query:
      nil ->
        case conn.query_string =~ "referer" do
          true ->
            query = URI.decode_query(conn.query_string)
            ref = Map.get(query, "referer")
            client_id = get_client_id_from_query(conn)
            ref |> URI.encode() |> append_client_id(client_id)

          #  no referer, redirect back to Auth app.
          false ->
            (AuthPlug.Helpers.get_baseurl_from_conn(conn) <> "/profile")
            |> URI.encode()
            |> append_client_id(AuthPlug.Token.client_id())
        end
    end
  end

  def get_client_id_from_query(conn) do
    case conn.query_string =~ "auth_client_id" do
      true ->
        Map.get(URI.decode_query(conn.query_string), "auth_client_id")

      #  no client_id, redirect back to this app.
      false ->
        0
    end
  end

  @doc """
  `github_auth/2` handles the callback from GitHub Auth API redirect.
  """
  def github_handler(conn, %{"code" => code, "state" => state}) do
    {:ok, profile} = ElixirAuthGithub.github_auth(code)
    # save profile to people:
    person = Person.create_github_person(profile)

    # login log
    user_agent =
      conn
      |> get_user_agent_string()
      |> Auth.UserAgent.get_or_insert_user_agent()

    ip_address = get_ip_address(conn)

    Auth.LoginLog.create_login_log(
      %{
        email: person.email,
        ip_address: ip_address,
        auth_provider: "github"
      },
      person,
      user_agent
    )

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

    # login log
    user_agent =
      conn
      |> get_user_agent_string()
      |> Auth.UserAgent.get_or_insert_user_agent()

    ip_address = get_ip_address(conn)

    Auth.LoginLog.create_login_log(
      %{
        email: person.email,
        ip_address: ip_address,
        auth_provider: "google"
      },
      person,
      user_agent
    )

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

  @doc """
  `redirect_or_render/3` does what it's name suggests,
  redirects if the `state` (HTTP referer) is defined
  or renders the default `:welcome` template.
  If the `auth_client_id` is undefined or invalid,
  render the `unauthorized/1` 401.
  """
  def redirect_or_render(conn, person, state) do
    # check if valid state (HTTP referer) is defined:

    case not (is_nil(state) or state == "") do
      # redirect
      true ->
        case get_client_secret_from_state(state) do
          0 ->
            unauthorized(conn)

          secret ->
            conn
            |> redirect(external: add_jwt_url_param(person, state, secret))
        end

      # display welcome page on Auth site:
      false ->
        conn
        |> AuthPlug.create_jwt_session(person)
        |> render(:welcome, person: person)
    end
  end

  # TODO: create a human-friendy response
  def unauthorized(conn) do
    conn
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
    p = params["person"]
    email = p["email"]
    state = p["state"]

    # email is blank or invalid:
    if is_nil(email) or not Fields.Validate.email(email) do
      # email invalid, re-render the login/register form:
      index(conn, params)
    else
      person = Auth.Person.get_person_by_email(email)

      # check if the email exists in the people table:
      person =
        if is_nil(person) do
          person =
            Auth.Person.create_person(%{
              email: email,
              auth_provider: "email"
            })

          Auth.Email.sendemail(%{
            email: email,
            template: "verify",
            link: make_verify_link(conn, person, state),
            subject: "Please Verify Your Email Address"
          })

          person
        else
          person
        end

      # login log
      user_agent =
        conn
        |> get_user_agent_string()
        |> Auth.UserAgent.get_or_insert_user_agent()

      ip_address = get_ip_address(conn)

      Auth.LoginLog.create_login_log(
        %{
          email: person.email,
          ip_address: ip_address
        },
        person,
        user_agent
      )

      password_form(conn, person, state)
    end
  end

  # setup password form depending on person values
  defp password_form(conn, person, state) do
    cond do
      is_nil(person.status) and is_nil(person.password_hash) ->
        # person has not verified their email address or created a password
        # TODO: pull out these messages into a translateable file.
        message = """
        You registered with the email address: #{person.email}. An email was sent
        to you with a link to confirm your address. Please check your email
        inbox for our message, open it and click the link.
        """

        render_password_form(conn, person.email, message, state, "password_create")

      person.status > 0 and is_nil(person.password_hash) ->
        # has verified but not yet defined a password
        render_password_form(conn, person.email, "", state, "password_create")

      is_nil(person.status) and not is_nil(person.password_hash) ->
        # person has not yet verified their email but has defined a password
        message = """
        You registered with the email address: #{person.email}. An email was sent
        to you with a link to confirm your address. Please check your email
        inbox for our message, open it and click the link.
        You can still login using the password you saved.
        """

        render_password_form(conn, person.email, message, state, "password_prompt")

      person.status > 0 and not is_nil(person.password_hash) ->
        # render password prompt without any put_flash message
        render_password_form(conn, person.email, "", state, "password_prompt")
    end
  end

  def render_password_form(conn, email, message, state, template) do
    conn
    |> put_flash(:info, message)
    |> assign(:action, Routes.auth_path(conn, String.to_atom(template)))
    |> render(template <> ".html",
      changeset: Auth.Person.password_new_changeset(%{email: email}),
      # so we can redirect after creatig a password
      state: state,
      email: AuthWeb.ApikeyController.encrypt_encode(email)
    )
  end

  @doc """
  `make_verify_link/3` creates a verfication link that gets included
  in the email we send to people to verify their email address.
  The person.id is encrypted and base58 encoded to avoid anyone verifying
  a different person's email. (not that anyone would do that, right? ;-)
  We include the original state (HTTP referer) so that the request can be
  redirected back to the desired page on successful verification.
  """
  def make_verify_link(conn, person, state) do
    AuthPlug.Helpers.get_baseurl_from_conn(conn) <>
      "/auth/verify?id=" <>
      AuthWeb.ApikeyController.encrypt_encode(person.id) <>
      "&referer=" <> state
  end

  # def password_input(conn, params) do
  #   conn
  #   |> assign(:action, Routes.auth_path(conn, :password_create))
  #   |> render("password_create.html",
  #     changeset: Auth.Person.password_new_changeset(%{email: params["email"]}),
  #     state: params["state"], # so we can redirect after creatig a password
  #     email: AuthWeb.ApikeyController.encrypt_encode(params["email"])
  #   )
  # end

  @doc """
  `password_create/2` is called when a new person is registering with email
  and is defining a password for the first time.
  Note: at present we are not enforcing any rules for password strength/length.
  Thinking of doing these checks as progressive enhancement in Browser.
  see:
  """
  def password_create(conn, params) do
    p = params["person"]
    email = Auth.Person.decrypt_email(p["email"])
    changeset = Auth.Person.password_new_changeset(%{email: email, password: p["password"]})

    if changeset.valid? do
      person = Auth.Person.upsert_person(%{email: email, password: p["password"]})
      redirect_or_render(conn, person, p["state"])
    else
      conn
      |> assign(:action, Routes.auth_path(conn, :password_create))
      |> render("password_create.html",
        changeset: changeset,
        state: p["state"],
        email: p["email"]
      )
    end
  end

  @doc """
  `password_prompt/2` handles all requests to verify a password for a person.
  If the pasword is verified (using Argon2.verify_pass), redirect to their
  desired page. If the password is invalid reset & re-render the form.
  TODO:
  """
  # verify the password
  def password_prompt(conn, params) do
    p = params["person"]
    email = Auth.Person.decrypt_email(p["email"])
    person = Auth.Person.get_person_by_email(email)

    case Argon2.verify_pass(p["password"], person.password_hash) do
      true ->
        redirect_or_render(conn, person, p["state"])

      false ->
        msg = """
        That password is incorrect.
        """

        render_password_form(conn, email, msg, p["state"], "password_prompt")
    end
  end

  def verify_email(conn, params) do
    id = AuthWeb.ApikeyController.decode_decrypt(params["id"])
    person = Auth.Person.verify_person_by_id(id)
    redirect_or_render(conn, person, params["referer"])
  end

  @doc """
  `get_client_secret_from_state/1` gets the client_id from state,
  attempts to decode_decrypt it and then look it up in apikeys
  if it finds the corresponding client_secret it returns the client_secret.
  All other failure conditions return a 0 (zero) which results in a 401.
  """
  def get_client_secret_from_state(state) do
    query = URI.decode_query(List.last(String.split(state, "?")))
    client_id = Map.get(query, "auth_client_id")

    case not is_nil(client_id) do
      # Lookup client_id in apikeys table
      true ->
        get_client_secret(client_id, state)

      # state without client_id is not valid
      false ->
        0
    end
  end

  def get_client_secret(client_id, state) do
    person_id = AuthWeb.ApikeyController.decode_decrypt(client_id)

    # decode_decrypt fails with state 0
    if person_id == 0 do
      0
    else
      apikeys = Auth.Apikey.list_apikeys_for_person(person_id)

      Enum.filter(apikeys, fn k ->
        k.client_id == client_id and state =~ k.url
      end)
      |> List.first()
      |> Map.get(:client_secret)
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

    List.first(String.split(URI.decode(state), "?")) <>
      "?jwt=" <> jwt
  end
end
