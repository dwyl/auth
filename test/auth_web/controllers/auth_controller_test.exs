defmodule AuthWeb.AuthControllerTest do
  use AuthWeb.ConnCase, async: true
  # @email System.get_env("ADMIN_EMAIL")

  @app_data %{
    "name" => "example key",
    "url" => "https://www.example.com",
    "person_id" => 1,
    "status" => 3
  }

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Sign in"
  end

  test "invoke index/2 with email and state", %{conn: conn} do
    person = non_admin_person()

    params = %{
      person: %{
        email: person.email,
        state: "any"
      }
    }

    conn = get(conn, "/", person: params)
    assert html_response(conn, 200) =~ "Sign in"
  end

  test "index/2 when logged in shows welcome page", %{conn: conn} do
    conn =
      conn
      |> non_admin_login()
      |> get("/")

    assert html_response(conn, 200) =~ "Welcome"
  end

  # this should prevent session hijacking by people with invalid client_id
  test "index/2 while logged in but with invalid auth_client_id", %{conn: conn} do
    client_id = String.slice(AuthPlug.Token.client_id(), 0..-3)

    conn =
      conn
      |> get(
        "/?referer=" <>
          URI.encode("http://localhost/admin") <>
          "&auth_client_id=" <> client_id
      )

    assert html_response(conn, 401) =~ "Sorry, client_id: #{client_id} is not valid"
  end

  # If logged into auth but consumer app attempt to login
  # with a referer and client id, display the login page
  test "index/2 while logged in app_id match", %{conn: conn} do
    url = "/?referer=" <> URI.encode("http://localhost/admin") <>
      "&auth_client_id=" <> AuthPlug.Token.client_id()
    conn =
      conn
      |> non_admin_login()
      |> get(url)

    assert html_response(conn, 200) =~ "Please Sign in to Continue"
  end

  # this should prevent session hijacking by people with invalid client_id
  test "index/2 match but app_id NOT match > index/2", %{conn: conn} do
    conn = non_admin_login(conn)
    app = create_app_for_person(conn.assigns.person)
    key = List.first(app.apikeys)

    conn =
      get(
        conn,
        "/?referer=" <>
          URI.encode("http://localhost/admin") <>
          "&auth_client_id=" <> key.client_id
      )

    assert html_response(conn, 200) =~ "Please Sign in to Continue"
  end

  test "GET /profile (without valid session should redirect)", %{conn: conn} do
    conn = get(conn, "/profile")
    # assert html_response(conn, 301) =~ "Login"
    assert conn.status == 302
  end

  test "admin/2 show welcome page", %{conn: conn} do
    data = %{
      email: "nelson@gmail.com",
      givenName: "McTestin",
      picture: "https://youtu.be/naoknj1ebqI",
      auth_provider: "google"
    }

    person = Auth.Person.create_person(data)

    conn =
      AuthPlug.create_jwt_session(conn, Map.merge(data, %{id: person.id}))
      |> get("/profile", %{})

    assert html_response(conn, 200) =~ "Google account"
  end

  test "get_referer/1 query_string", %{conn: conn} do
    conn =
      get(
        conn,
        "/?referer=" <>
          URI.encode("http://localhost/admin") <>
          "&auth_client_id=" <> AuthPlug.Token.client_id()
      )

    assert conn.resp_body =~ "state=http://localhost/admin"
  end

  # Fail Early on invalid client_id test for: github.com/dwyl/auth/issues/129
  test "index/2 (not logged in) invalid auth_client_id", %{conn: conn} do
    conn =
      get(
        conn,
        "/?referer=" <>
          URI.encode("http://localhost/admin") <>
          "&auth_client_id=" <> String.slice(AuthPlug.Token.client_id(), 0..-2)
      )

    assert html_response(conn, 401) =~ "not valid"
  end

  # regression test for: https://github.com/dwyl/auth/issues/135
  test "append_client_id/2 unit test" do
    assert AuthWeb.AuthController.append_client_id("ref", nil) == "ref"
  end

  test "get_client_secret(client_id, state) gets the secret for the given client_id" do
    {:ok, app} = Auth.App.create_app(@app_data)
    key = List.first(app.apikeys)
    state = "https://www.example.com/profile?auth_client_id=#{key.client_id}"
    secret = AuthWeb.AuthController.get_client_secret(key.client_id, state)
    assert secret == key.client_secret
  end

  test "get_client_secret/2 for non_admin key" do
    person = non_admin_person()
    app_data = Map.merge(@app_data, %{"person_id" => person.id})
    {:ok, app} = Auth.App.create_app(app_data)
    key = List.first(app.apikeys)
    state = "#{app.url}/profile?auth_client_id=#{key.client_id}"
    secret = AuthWeb.AuthController.get_client_secret(key.client_id, state)
    assert secret == key.client_secret
  end

  test "get_client_secret(client_id, state) for 'deleted' apikey (non-admin)" do
    person = non_admin_person()
    {:ok, app} = Auth.App.create_app(Map.merge(@app_data, %{"person_id" => person.id}))
    key = List.first(app.apikeys)
    Auth.Apikey.update_apikey(Map.delete(key, :app), %{status: 6})
    state = "#{app.url}/profile?auth_client_id=#{key.client_id}"
    secret = AuthWeb.AuthController.get_client_secret(key.client_id, state)
    # 0 is our failure condition
    assert secret == 0
  end

  # TBD:
  # test "redirect_or_render assigns app_admin role if direct auth", %{conn: conn} do
  #   conn = non_admin_login(conn)
  #   IO.inspect(conn, label: "conn:96")
  #   person = conn.assigns.person
  #   IO.inspect(person, label: "person:98")

  #   AuthWeb.AuthController.redirect_or_render(conn, person, "")
  #   IO.inspect(conn, label: "conn:100")
  # end

  test "github_handler/2 github auth callback", %{conn: conn} do
    baseurl = AuthPlug.Helpers.get_baseurl_from_conn(conn)

    data = %{
      code: "123",
      state:
        baseurl <>
          "&auth_client_id=" <> AuthPlug.Token.client_id()
    }

    conn2 = get(conn, "/auth/github/callback", data)
    assert html_response(conn2, 302) =~ baseurl
  end

  # unit test for lookup by github_id for github.com/dwyl/auth/issues/125
  test "create_github_person/1 lookup by github_id" do
    person = non_admin_person()

    github_profile = %{
      id: 19,
      name: "Unit Tests Are Awesome",
      login: "awesome",
      avatar_url: "https://a.io",
      email: person.email
    }

    # this will exercise the "not nil" branch:
    github_person = Auth.Person.create_github_person(github_profile)
    assert github_person.givenName == github_profile.name
  end

  test "google_handler/2 for google auth callback", %{conn: conn} do
    baseurl = AuthPlug.Helpers.get_baseurl_from_conn(conn)

    conn =
      get(conn, "/auth/google/callback", %{
        code: "234",
        state:
          baseurl <>
            "?auth_client_id=" <> AuthPlug.Token.client_id()
      })

    # assert html_response(conn, 200) =~ "nelson@gmail.com"
    assert html_response(conn, 302) =~ baseurl
  end

  test "google_handler/2 show welcome page", %{conn: conn} do
    # Google Auth Mock makes the state https://www.example.com
    # so we need to create a new API_KEY with that url:
    {:ok, app} = Auth.App.create_app(@app_data)
    key = List.first(app.apikeys)

    conn =
      get(conn, "/auth/google/callback", %{
        code: "234",
        state:
          AuthPlug.Helpers.get_baseurl_from_conn(conn) <>
            "&auth_client_id=" <> key.client_id
      })

    # assert html_response(conn, 200) =~ "nelson@gmail.com"
    assert html_response(conn, 302) =~ "redirected"
  end

  test "google_handler/2 show welcome (state=nil) > handler/3", %{conn: conn} do
    rand = :rand.uniform(1_000_000)
    data = %{
      email: "nelson#{rand}@gmail.com",
      id: rand,
      givenName: "McTestin",
      picture: "https://youtu.be/naoknj1ebqI",
      auth_provider: "google"
    }

    Auth.Person.upsert_person(data)

    conn =
      AuthPlug.create_jwt_session(conn, data)
      |> get("/auth/google/callback", %{"code" => "234", "state" => nil})

    assert html_response(conn, 200) =~ "Google account"
  end

  test "google_handler/2 with invalid client_id", %{conn: conn} do
    invalid_key = String.slice(AuthPlug.Token.client_id(), 0..-2)

    conn =
      get(conn, "/auth/google/callback", %{
        code: "234",
        state:
          "www.example.com/" <>
            "&auth_client_id=" <> invalid_key
      })

    # assert html_response(conn, 200) =~ "google account"
    assert html_response(conn, 401) =~ "invalid"
  end

  test "login_register_handler/2 with invalid email", %{conn: conn} do
    conn =
      conn
      |> put_req_header("user-agent", "user-agent-1")
      |> post("/auth/loginregister", %{
        "person" => %{
          email: "invalid",
          state:
            "www.example.com/" <>
              "&auth_client_id=" <> AuthPlug.Token.client_id()
        }
      })

    # re-render the index
    assert html_response(conn, 200) =~ "email"
    # assert html_response(conn, 401) =~ "invalid"
  end

  test "login_register_handler/2 with valid email", %{conn: conn} do
    rand = :rand.uniform(1_000_000)
    conn =
      post(conn, "/auth/loginregister", %{
        "person" => %{
          email: "jimmy#{rand}@dwyl.com",
          state:
            "www.example.com/" <>
              "&auth_client_id=" <> AuthPlug.Token.client_id()
        }
      })

    # TODO: show password form!
    # assert html_response(conn, 302) =~ "redirected"
    assert html_response(conn, 200) =~ "New Password"
    # assert html_response(conn, 401) =~ "invalid"
  end

  test "login_register_handler/2 UNVERIFIED and NO PASSWORD", %{conn: conn} do
    rand = :rand.uniform(1_000_000)
    data = %{
      id: rand,
      email: "alice#{rand}@gmail.com",
      auth_provider: "email"
    }

    person = Auth.Person.upsert_person(data)

    conn =
      post(conn, "/auth/loginregister", %{
        "person" => %{
          email: person.email,
          state:
            "www.example.com/" <>
              "&auth_client_id=" <> AuthPlug.Token.client_id()
        }
      })

    # expect to see put_flash informing person to click verify email:
    assert html_response(conn, 200) =~ "email was sent"
    # instruct them to create a New Password (registration):
    assert conn.resp_body =~ "Please Create a New Password"
  end

  test "login_register_handler/2 has VERIFIED but NO PASSWORD", %{conn: conn} do
    data = %{
      email: "alan@gmail.com",
      auth_provider: "email",
      status: 1
    }

    person = Auth.Person.upsert_person(data)

    conn =
      post(conn, "/auth/loginregister", %{
        "person" => %{
          email: person.email,
          state:
            "www.example.com/" <>
              "&auth_client_id=" <> AuthPlug.Token.client_id()
        }
      })

    # instruct them to create a New Password (registration):
    assert conn.resp_body =~ "Please Create a New Password"
  end

  test "login_register_handler/2 UNVERIFIED person with PWD", %{conn: conn} do
    rand = :rand.uniform(1_000_000)
    data = %{
      id: rand,
      email: "alex#{rand}@gmail.com",
      auth_provider: "email",
      password: "thiswillbehashed"
    }

    person = Auth.Person.upsert_person(data)

    conn =
      post(conn, "/auth/loginregister", %{
        "person" => %{
          email: person.email,
          state:
            "www.example.com/" <>
              "&auth_client_id=" <> AuthPlug.Token.client_id()
        }
      })

    # expect to see put_flash informing person to click verify email:
    # assert html_response(conn, 200) =~ "email was sent"
    # they can/should still login using the password they defined:
    assert conn.resp_body =~ "Input Your Password"
  end

  test "login_register_handler/2 has VERIFIED and PASSWORD", %{conn: conn} do
    rand = :rand.uniform(1_000_000)
    data = %{
      auth_provider: "email",
      email: "ana#{rand}@gmail.com",
      id: rand,
      password: "thiswillbehashed",
      status: 1
    }

    person = Auth.Person.upsert_person(data)

    conn =
      post(conn, "/auth/loginregister", %{
        "person" => %{
          email: person.email,
          state:
            "www.example.com/" <>
              "&auth_client_id=" <> AuthPlug.Token.client_id()
        }
      })

    # person can login with their existing password:
    assert conn.resp_body =~ "Input Your Password"
  end

  test "password_create/2 create a new password", %{conn: conn} do
    rand = :rand.uniform(1_000_000)
    %{
      app_id: 1,
      auth_provider: "email",
      email: "anabela#{rand}@mail.com",
      givenName: "timmy",
      id: rand
    }
    |> Auth.Person.upsert_person()

    params = %{
      "person" => %{
        "email" => Auth.Apikey.encrypt_encode("anabela#{rand}@mail.com"),
        "password" => "thiswillbehashed"
      }
    }

    conn = post(conn, "/auth/password/create", params)
    assert html_response(conn, 200) =~ "Welcome"
  end

  test "password_create/2 display form when password not valid", %{conn: conn} do
    params = %{
      "person" => %{
        "email" => Auth.Apikey.encrypt_encode("anabela@mail.com"),
        "password" => "short"
      }
    }

    conn = post(conn, "/auth/password/create", params)
    assert html_response(conn, 200) =~ "Password"
  end

  test "verify_email/2 verify an email address", %{conn: conn} do
    rand = :rand.uniform(1_000_000)
    person =
      %{email: "anabela#{rand}@mail.com", auth_provider: "email", app_id: 1, id: rand}
      |> Auth.Person.upsert_person()

    state =
      AuthPlug.Helpers.get_baseurl_from_conn(conn) <>
        "/profile?auth_client_id=" <> AuthPlug.Token.client_id()

    link = AuthWeb.AuthController.make_verify_link(conn, person, state)
    link = "/auth/verify" <> List.last(String.split(link, "/auth/verify"))

    conn = get(conn, link, %{})
    assert html_response(conn, 302) =~ "redirected"
  end

  test "verify_email/2 verify email with wrong API key", %{conn: conn} do
    link = "/auth/verify?id=wrongid"

    conn = get(conn, link, %{})
    assert html_response(conn, 401)
  end

  test "password_prompt/2 verify VALID password", %{conn: conn} do
    rand = :rand.uniform(1_000_000)
    data = %{
      id: rand,
      email: "ana#{rand}@mail.com",
      auth_provider: "email",
      status: 1,
      password: "thiswillbehashed",
      app_id: 1
    }

    Auth.Person.upsert_person(data)

    state =
      AuthPlug.Helpers.get_baseurl_from_conn(conn) <>
        "/profile?auth_client_id=" <> AuthPlug.Token.client_id()

    params = %{
      "person" => %{
        "email" => Auth.Apikey.encrypt_encode(data.email),
        "password" => "thiswillbehashed",
        "state" => state
      }
    }

    conn = post(conn, "/auth/password/verify", params)
    assert html_response(conn, 302) =~ "redirected"
  end

  test "password_prompt/2 verify INVALID password", %{conn: conn} do
    rand = :rand.uniform(1_000_000)
    data = %{
      email: "ana#{rand}@mail.com",
      id: rand,
      auth_provider: "email",
      status: 1,
      password: "thiswillbehashed"
    }

    Auth.Person.upsert_person(data)

    state =
      AuthPlug.Helpers.get_baseurl_from_conn(conn) <>
        "/profile?auth_client_id=" <> AuthPlug.Token.client_id()

    params = %{
      "person" => %{
        "email" => Auth.Apikey.encrypt_encode(data.email),
        "password" => "fail",
        "state" => state
      }
    }

    conn = post(conn, "/auth/password/verify", params)
    assert html_response(conn, 200) =~ "password is incorrect"
  end

  test "/logout of the auth app", %{conn: conn} do
    conn2 = conn |> admin_login() |> get("/logout", %{})
    assert html_response(conn2, 200) =~ "Successfully logged out."
  end

  test "client_id_is_current? nil path" do
    assert AuthWeb.AuthController.client_id_is_current?(0, 1) == false
  end
end
