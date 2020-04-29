defmodule AuthWeb.AuthControllerTest do
  use AuthWeb.ConnCase
  # @email System.get_env("ADMIN_EMAIL")

  test "github_handler/2 github auth callback", %{conn: conn} do
    conn = get(conn, "/auth/github/callback",
      %{code: "123", state: "http://localhost:4000/" <>
      "&auth_client_id=" <> AuthPlug.Token.client_id() })
    # assert html_response(conn, 200) =~ "test@gmail.com"
    assert html_response(conn, 302) =~ "http://localhost"
  end

  test "google_handler/2 for google auth callback", %{conn: conn} do
    conn = get(conn, "/auth/google/callback",
      %{code: "234", state: "http://localhost:4000" <>
      "&auth_client_id=" <> AuthPlug.Token.client_id() })

    # assert html_response(conn, 200) =~ "nelson@gmail.com"
    assert html_response(conn, 302) =~ "http://localhost"
  end

  test "google_handler/2 show welcome page", %{conn: conn} do
    # IO.inspect(AuthPlug.Helpers.get_baseurl_from_conn(conn), label: "baseurl")
    # Google Auth Mock makes the state https://www.example.com
    # so we need to create a new API_KEY with that url:
    {:ok, key} = %{"name" => "example key", "url" => "https://www.example.com"}
      |> AuthWeb.ApikeyController.make_apikey(1)
      |> Auth.Apikey.create_apikey()

    conn = get(conn, "/auth/google/callback",
      %{code: "234",
      state: AuthPlug.Helpers.get_baseurl_from_conn(conn) <>
      "&auth_client_id=" <> key.client_id })

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
    person = Auth.Person.create_person(data) # |> IO.inspect(label: "person")
    conn = AuthPlug.create_jwt_session(conn, Map.merge(data, person))
    conn = get(conn, "/auth/google/callback",
      %{code: "234", state: nil})

    assert html_response(conn, 200) =~ "google account"
    # assert html_response(conn, 302) =~ "redirected"
  end

  test "google_handler/2 with invalid client_id", %{conn: conn} do
    invalid_key = String.slice(AuthPlug.Token.client_id(), 0..-2)
    conn = get(conn, "/auth/google/callback",
      %{code: "234", state: "www.example.com/" <>
      "&auth_client_id=" <> invalid_key })
    # assert html_response(conn, 200) =~ "google account"
    assert html_response(conn, 401) =~ "invalid"
  end


end
