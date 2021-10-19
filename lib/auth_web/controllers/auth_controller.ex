defmodule AuthWeb.AuthController do
  @moduledoc """
  Defines AuthController and all functions for authenticaiton
  """
  use AuthWeb, :controller
  alias Auth.App
  alias Auth.Person

  # https://github.com/dwyl/auth/issues/46
  def admin(conn, _params) do
    render(conn, :welcome, apps: App.list_apps(conn.assigns.person.id))
  end

  # route the request based on conn.assigns.person.app_id == app_id
  defp check_app_id(conn, params, app_id, state) do
    if conn.assigns.person.app_id == app_id do
      msg = "person: #{conn.assigns.person.id} already logged into app: #{app_id}"

      conn
      |> Auth.Log.info(Map.merge(params, %{msg: msg}))
      # already logged-in so redirect back to app:
      |> redirect_or_render(conn.assigns.person, state)
    else
      # app_id does not match, force login:mix
      msg = "auth_client_id (#{app_id}) does not match, please login (check_app_id:25)"
      # remove the conn.assigns.person and jwt to avoid match loop
      conn = update_in(conn.assigns, &Map.drop(&1, [:person, :jwt]))

      conn
      |> Auth.Log.error(Map.merge(params, %{status: 401, msg: msg}))
      |> put_flash(:error, msg)
      # force re-auth as for a different app with different roles, etc.
      |> index(params)
    end
  end

  # Handle requests where already authenticated: github.com/dwyl/auth/issues/69
  def index(%{assigns: %{person: _}} = conn, params) do
    # Check if currently authenticated for app: github.com/dwyl/auth/issues/130
    case get_client_id_from_query(conn) do
      # no auth_client_id means the request is for auth app
      nil ->
        Auth.Log.info(conn, params)
        redirect_or_render(conn, conn.assigns.person, nil)

      client_id ->
        msg = "request with client_id: #{client_id} (index:48)"
        Auth.Log.info(conn, Map.merge(params, %{msg: msg}))

        case Auth.Apikey.decode_decrypt(client_id) do
          #  if there is a client_id in the URL but we cannot decrypt it, reject!
          {:error, _} ->
            Auth.Log.info(conn, Map.merge(params, %{msg: msg}))
            unauthorized(conn, "invalid AUTH_API_KEY (index:55)")

          # able to decrypt the client_id let's see if it matches
          {:ok, app_id} ->
            referer = get_referer(conn)
            check_app_id(conn, params, app_id, referer)
        end
    end
  end

  def index(conn, params) do
    client_id = get_client_id_from_query(conn)
    valid_client_id = client_id && client_id_valid?(client_id, conn)

    # Log authentication information, see https://github.com/dwyl/auth/issues/129
    # This will save in the database the status for each login attempt
    log_auth(conn, params, client_id, valid_client_id)

    # if the client_id is not defined, the user then login in Auth app
    # if client_id defined and valid we still display the login UI, Auth will redirect to the user app
    if is_nil(client_id) or valid_client_id do
      render_login_buttons(conn, params)
    else
      error_message = "client_id: #{client_id} is not valid"

      conn
      |> put_flash(:error, error_message)
      |> unauthorized(error_message)
    end
  end

  # log authentication
  # client_id is not defined as query parameter, ie auth on Auth app
  defp log_auth(conn, params, nil, _), do: Auth.Log.info(conn, params)

  # client_id defined and valid
  defp log_auth(conn, params, client_id, true) do
    msg = "request with client_id: #{client_id} index in auth controller"
    Auth.Log.info(conn, Map.merge(params, %{msg: msg}))
  end

  # client_id not valid
  defp log_auth(conn, params, client_id, false) do
    msg = "auth_client_id: #{client_id} is not valid index in auth controller"
    Auth.Log.error(conn, Map.merge(params, %{msg: msg}))
  end

  # render the login page with appropriate redirections
  def render_login_buttons(conn, params) do
    referer = get_referer(conn)
    oauth_github_url = ElixirAuthGithub.login_url(%{scopes: ["user:email"], state: referer})
    oauth_google_url = ElixirAuthGoogle.generate_oauth_url(conn, referer)

    conn
    |> Auth.Log.info(Map.merge(params, %{msg: "render_login_buttons:92 state: #{referer}"}))
    |> assign(:action, Routes.auth_path(conn, :login_register_handler))
    |> render("index.html",
      oauth_github_url: oauth_github_url,
      oauth_google_url: oauth_google_url,
      changeset: Auth.Person.login_register_changeset(%{}),
      state: referer
    )
  end

  # confirm that the client_id is valid for the app:
  # returns the app_id from client_id as app_id is used to create client id and secret
  def client_id_valid?(client_id, conn) do
    # attempt to decrypt the client_id
    case Auth.Apikey.decode_decrypt(client_id) do
      # if auth_client_id in the URL but we cannot decrypt it, reject early!
      # see: https://github.com/dwyl/auth/issues/129
      {:error, _} ->
        msg = "client_id_valid?:109 Unable to decrypt auth_client_id:#{client_id}"
        Auth.Log.error(conn, %{msg: msg})
        false

      # able to decrypt the client_id to an app_id check if still valid:
      {:ok, app_id} ->
        client_id_is_current?(app_id, client_id)
    end
  end

  # return true if the app_id is linked to the client_id otherwise false
  # Check if the api key hasn't been deleted
  defp client_id_is_current?(app_id, client_id) do
    case Auth.Apikey.get_apikey_by_app_id(app_id) do
      nil ->
        false

      apikey ->
        apikey.client_id == client_id
    end
  end

  # do not append the client id if it doesn't exist, see #135
  def append_client_id(referer, nil), do: referer
  def append_client_id(referer, client_id), do: "#{referer}?auth_client_id=#{client_id}"

  def get_referer(conn) do
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

  # returns the auth_client_id or nil if it doesn't exist in the query
  def get_client_id_from_query(conn), do: conn.query_params["auth_client_id"]

  @doc """
  `github_auth/2` handles the callback from GitHub Auth API redirect.
  """
  def github_handler(conn, %{"code" => code, "state" => state}) do
    {:ok, profile} = ElixirAuthGithub.github_auth(code)
    app_id = get_app_id(state)

    # save profile to people:
    person = Person.create_github_person(Map.merge(profile, %{app_id: app_id}))

    # render or redirect:
    handler(conn, person, state)
  end

  def get_app_id(state) do
    client_secret =
      state
      |> get_client_secret_from_state()
      |> Auth.Apikey.decode_decrypt()

    case client_secret do
      {:ok, app_id} -> app_id
      {:error, _} -> 1
    end
  end

  @doc """
  `google_handler/2` handles the callback from Google Auth API redirect.
  """
  def google_handler(conn, %{"code" => code, "state" => state}) do
    {:ok, token} = ElixirAuthGoogle.get_token(code, conn)
    {:ok, profile} = ElixirAuthGoogle.get_user_profile(token.access_token)
    # save profile to people:
    app_id = get_app_id(state)
    person = Person.create_google_person(Map.merge(profile, %{app_id: app_id}))

    # render or redirect:
    handler(conn, person, state)
  end

  @doc """
  `handler/3` responds to successful auth requests.
  if the state is defined, redirect to it.
  """
  def handler(conn, person, state) do
    # Send welcome email: temporarily disabled to avoid noise.
    # Auth.Email.sendemail(%{
    #   email: person.email,
    #   name: person.givenName,
    #   template: "welcome"
    # })
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
    if is_nil(state) or state == "" do
      # No State > Display Welcome page on Auth site:
      conn
      |> AuthPlug.create_jwt_session(session_data(person))
      |> Auth.Log.info(%{status_id: 200, app_id: 1})
      |> render(:welcome, person: person, apps: App.list_apps(person.id))
    else
      # State > Redirect to requesting app:
      case get_client_secret_from_state(state) do
        0 ->
          unauthorized(conn, "invalid AUTH_API_KEY")

        secret ->
          conn
          |> AuthPlug.create_jwt_session(session_data(person))
          |> Auth.Log.info(%{status_id: 200, app_id: get_app_id(state)})
          |> redirect(external: add_jwt_url_param(person, state, secret))
      end
    end
  end

  def error(conn, msg, status) do
    # https://hexdocs.pm/phoenix/Phoenix.Controller.html#get_format/1
    if get_format(conn) == "json" do
      data = %{status_id: status, msg: msg}

      conn
      |> Auth.Log.error(data)
      |> put_status(status)
      |> json(data)
    else
      conn
      |> Auth.Log.error(%{status_id: status, msg: msg})
      |> put_status(status)
      |> assign(:reason, %{message: msg})
      |> put_view(AuthWeb.ErrorView)
      |> render("404.html", conn: conn)
    end
  end

  def unauthorized(conn, msg \\ "invalid AUTH_API_KEY/client_id please check") do
    error(conn, msg, 401)
  end

  def not_found(conn, msg) do
    error(conn, msg, 404)
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
    app_id = get_app_id(state)

    # email is blank or invalid:
    if is_nil(email) or not Fields.Validate.email(email) do
      Auth.Log.error(conn, %{email: email, app_id: app_id, status_id: 401, msg: "email invalid"})

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
      email: Auth.Apikey.encrypt_encode(email)
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
      Auth.Apikey.encrypt_encode(person.id) <>
      "&referer=" <> state
  end

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
      # replace %Auth.Role{} struct with string  github.com/dwyl/rbac/issues/4
      person = Map.replace!(person, :roles, RBAC.transform_role_list_to_string(person.roles))
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
  """
  def password_prompt(conn, params) do
    p = params["person"]
    email = Auth.Person.decrypt_email(p["email"])
    person = Auth.Person.get_person_by_email(email)
    state = p["state"]
    app_id = get_app_id(state)

    case Argon2.verify_pass(p["password"], person.password_hash) do
      true ->
        redirect_or_render(conn, person, p["state"])

      false ->
        msg = """
        That password is incorrect.
        """

        Auth.Log.error(conn, %{email: email, app_id: app_id, status_id: 401})
        render_password_form(conn, email, msg, p["state"], "password_prompt")
    end
  end

  def verify_email(conn, params) do
    {:ok, id} = Auth.Apikey.decode_decrypt(params["id"])
    person = Auth.Person.verify_person_by_id(id)
    redirect_or_render(conn, person, params["referer"])
  end

  def get_client_id_from_state(state) do
    state
    |> String.split("?")
    |> List.last()
    |> URI.decode_query()
    |> Map.get("auth_client_id")
  end

  @doc """
  `get_client_secret_from_state/1` gets the client_id from state,
  attempts to decode_decrypt it and then look it up in apikeys
  if it finds the corresponding client_secret it returns the client_secret.
  All other failure conditions return a 0 (zero) which results in a 401.
  """
  def get_client_secret_from_state(state) do
    client_id = get_client_id_from_state(state)

    # Lookup client_id in apikeys table
    # or state without client_id is not valid
    if is_nil(client_id), do: 0, else: get_client_secret(client_id, state)
  end

  def get_client_secret(client_id, state) do
    # decode_decrypt fails with 0:
    case Auth.Apikey.decode_decrypt(client_id) do
      {:error, _} ->
        0

      {:ok, app_id} ->
        apikey = Auth.Apikey.get_apikey_by_app_id(app_id)

        cond do
          # if the apikey isn't found it will be nil
          is_nil(apikey) ->
            0

          apikey.app.person_id == 1 ->
            apikey.client_secret

          # all other keys require matching the app url and status to not be "deleted":
          apikey.client_id == client_id && state =~ apikey.app.url && apikey.status != 6 ->
            apikey.client_secret

          true ->
            0
        end
    end
  end

  def session_data(person) do
    roles =
      if Map.has_key?(person, :roles) do
        RBAC.transform_role_list_to_string(person.roles)
      else
        nil
      end

    %{
      auth_provider: person.auth_provider,
      givenName: person.givenName,
      id: person.id,
      picture: person.picture,
      status: person.status,
      email: person.email,
      roles: roles,
      app_id: person.app_id
    }
  end

  def add_jwt_url_param(person, state, client_secret) do
    jwt = AuthPlug.Token.generate_jwt!(session_data(person), client_secret)

    List.first(String.split(URI.decode(state), "?")) <>
      "?jwt=" <> jwt
  end
end
