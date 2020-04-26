defmodule AuthWeb.AuthControllerTest do
  use AuthWeb.ConnCase
  # @email System.get_env("ADMIN_EMAIL")

  test "github_handler/2 github auth callback", %{conn: conn} do
    conn = get(conn, "/auth/github/callback",
      %{code: "123", state: "http://localhost/"})
    # assert html_response(conn, 200) =~ "test@gmail.com"
    assert html_response(conn, 302) =~ "http://localhost"
  end

  test "google_handler/2 for google auth callback", %{conn: conn} do
    conn = get(conn, "/auth/google/callback",
      %{code: "234", state: "http://localhost/"})

    # assert html_response(conn, 200) =~ "nelson@gmail.com"
    assert html_response(conn, 302) =~ "http://localhost"
  end

  test "google_handler/2 show welcome page", %{conn: conn} do
    conn = get(conn, "/auth/google/callback",
      %{code: "234", state: AuthPlug.Helpers.get_baseurl_from_conn(conn)})

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
    conn = AuthPlug.create_jwt_session(conn, Map.merge(data, %{id: person.id}))
    conn = get(conn, "/auth/google/callback",
      %{code: "234", state: nil})

    assert html_response(conn, 200) =~ "google account"
    # assert html_response(conn, 302) =~ "redirected"
  end

  # test "handler/3 show welcome page", %{conn: conn} do
  #
  #   person = Auth.Person.create_person(%{
  #     email: "test@gmail.com", givenName: "McTestin"
  #   })
  #   IO.inspect(person, label: "person")
  #
  #   conn = AuthPlug.create_jwt_session(conn, %{email: person.email, id: person.id})
  #   conn = AuthWeb.AuthController.handler(conn, person, nil)
  #   IO.inspect(conn, label: "conn")
  #   # assert html_response(conn, 302) =~ "redirected"
  # end
end
