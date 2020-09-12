defmodule AuthWeb.AuthControllerTest do
  use AuthWeb.ConnCase
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

  test "get_referer/1", %{conn: conn} do
    conn =
      conn
      |> put_req_header("referer", "http://localhost/admin")
      |> get("/")

    assert conn.resp_body =~ "state=http://localhost/admin"
  end

  test "get_referer/1 query_string", %{conn: conn} do
    conn =
      conn
      |> get(
        "/?referer=" <>
          URI.encode("http://localhost/admin") <>
          "&auth_client_id=" <> AuthPlug.Token.client_id()
      )

    assert conn.resp_body =~ "state=http://localhost/admin"
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
    # Note: not sure what to assert here ... ¯\_(ツ)_/¯
    # The API Key is "deleted" so it won't be found in the lookup
    try do
      AuthWeb.AuthController.get_client_secret(key.client_id, state)
    rescue
      e in BadMapError -> assert e == %BadMapError{term: nil}
    end
  end

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

    conn =
      get(conn, "/auth/github/callback", %{
        code: "123",
        state:
          baseurl <>
            "&auth_client_id=" <> AuthPlug.Token.client_id()
      })

    # assert html_response(conn, 200) =~ "test@gmail.com"
    assert html_response(conn, 302) =~ baseurl
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
    data = %{
      email: "nelson@gmail.com",
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
    conn =
      post(conn, "/auth/loginregister", %{
        "person" => %{
          email: "jimmy@dwyl.com",
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
    data = %{
      email: "alice@gmail.com",
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
    data = %{
      email: "alex@gmail.com",
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
    assert html_response(conn, 200) =~ "email was sent"
    # they can/should still login using the password they defined:
    assert conn.resp_body =~ "Input Your Password"
  end

  test "login_register_handler/2 has VERIFIED and PASSWORD", %{conn: conn} do
    data = %{
      email: "ana@gmail.com",
      auth_provider: "email",
      status: 1,
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

    # person can login with their existing password:
    assert conn.resp_body =~ "Input Your Password"
  end

  test "password_create/2 create a new password", %{conn: conn} do
    %{email: "anabela@mail.com", auth_provider: "email"}
    |> Auth.Person.upsert_person()

    params = %{
      "person" => %{
        "email" => Auth.Apikey.encrypt_encode("anabela@mail.com"),
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
    person =
      %{email: "anabela@mail.com", auth_provider: "email"}
      |> Auth.Person.upsert_person()

    state =
      AuthPlug.Helpers.get_baseurl_from_conn(conn) <>
        "/profile?auth_client_id=" <> AuthPlug.Token.client_id()

    link = AuthWeb.AuthController.make_verify_link(conn, person, state)
    link = "/auth/verify" <> List.last(String.split(link, "/auth/verify"))

    conn = get(conn, link, %{})
    assert html_response(conn, 302) =~ "redirected"
  end

  test "password_prompt/2 verify VALID password", %{conn: conn} do
    data = %{
      email: "ana@mail.com",
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
        "password" => "thiswillbehashed",
        "state" => state
      }
    }

    conn = post(conn, "/auth/password/verify", params)
    assert html_response(conn, 302) =~ "redirected"
  end

  test "password_prompt/2 verify INVALID password", %{conn: conn} do
    data = %{
      email: "ana@mail.com",
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
end
