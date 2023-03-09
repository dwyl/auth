defmodule AuthWeb.PersonAuthTest do
  use AuthWeb.ConnCase, async: true

  alias Phoenix.LiveView
  alias Auth.Accounts
  alias AuthWeb.PersonAuth
  import Auth.AccountsFixtures

  @remember_me_cookie "_auth_web_person_remember_me"

  setup %{conn: conn} do
    conn =
      conn
      |> Map.replace!(:secret_key_base, AuthWeb.Endpoint.config(:secret_key_base))
      |> init_test_session(%{})

    %{person: person_fixture(), conn: conn}
  end

  describe "log_in_person/3" do
    test "stores the person token in the session", %{conn: conn, person: person} do
      conn = PersonAuth.log_in_person(conn, person)
      assert token = get_session(conn, :person_token)
      assert get_session(conn, :live_socket_id) == "people_sessions:#{Base.url_encode64(token)}"
      assert redirected_to(conn) == ~p"/"
      assert Accounts.get_person_by_session_token(token)
    end

    test "clears everything previously stored in the session", %{conn: conn, person: person} do
      conn = conn |> put_session(:to_be_removed, "value") |> PersonAuth.log_in_person(person)
      refute get_session(conn, :to_be_removed)
    end

    test "redirects to the configured path", %{conn: conn, person: person} do
      conn = conn |> put_session(:person_return_to, "/hello") |> PersonAuth.log_in_person(person)
      assert redirected_to(conn) == "/hello"
    end

    test "writes a cookie if remember_me is configured", %{conn: conn, person: person} do
      conn = conn |> fetch_cookies() |> PersonAuth.log_in_person(person, %{"remember_me" => "true"})
      assert get_session(conn, :person_token) == conn.cookies[@remember_me_cookie]

      assert %{value: signed_token, max_age: max_age} = conn.resp_cookies[@remember_me_cookie]
      assert signed_token != get_session(conn, :person_token)
      assert max_age == 5_184_000
    end
  end

  describe "logout_person/1" do
    test "erases session and cookies", %{conn: conn, person: person} do
      person_token = Accounts.generate_person_session_token(person)

      conn =
        conn
        |> put_session(:person_token, person_token)
        |> put_req_cookie(@remember_me_cookie, person_token)
        |> fetch_cookies()
        |> PersonAuth.log_out_person()

      refute get_session(conn, :person_token)
      refute conn.cookies[@remember_me_cookie]
      assert %{max_age: 0} = conn.resp_cookies[@remember_me_cookie]
      assert redirected_to(conn) == ~p"/"
      refute Accounts.get_person_by_session_token(person_token)
    end

    test "broadcasts to the given live_socket_id", %{conn: conn} do
      live_socket_id = "people_sessions:abcdef-token"
      AuthWeb.Endpoint.subscribe(live_socket_id)

      conn
      |> put_session(:live_socket_id, live_socket_id)
      |> PersonAuth.log_out_person()

      assert_receive %Phoenix.Socket.Broadcast{event: "disconnect", topic: ^live_socket_id}
    end

    test "works even if person is already logged out", %{conn: conn} do
      conn = conn |> fetch_cookies() |> PersonAuth.log_out_person()
      refute get_session(conn, :person_token)
      assert %{max_age: 0} = conn.resp_cookies[@remember_me_cookie]
      assert redirected_to(conn) == ~p"/"
    end
  end

  describe "fetch_current_person/2" do
    test "authenticates person from session", %{conn: conn, person: person} do
      person_token = Accounts.generate_person_session_token(person)
      conn = conn |> put_session(:person_token, person_token) |> PersonAuth.fetch_current_person([])
      assert conn.assigns.current_person.id == person.id
    end

    test "authenticates person from cookies", %{conn: conn, person: person} do
      logged_in_conn =
        conn |> fetch_cookies() |> PersonAuth.log_in_person(person, %{"remember_me" => "true"})

      person_token = logged_in_conn.cookies[@remember_me_cookie]
      %{value: signed_token} = logged_in_conn.resp_cookies[@remember_me_cookie]

      conn =
        conn
        |> put_req_cookie(@remember_me_cookie, signed_token)
        |> PersonAuth.fetch_current_person([])

      assert conn.assigns.current_person.id == person.id
      assert get_session(conn, :person_token) == person_token

      assert get_session(conn, :live_socket_id) ==
               "people_sessions:#{Base.url_encode64(person_token)}"
    end

    test "does not authenticate if data is missing", %{conn: conn, person: person} do
      _ = Accounts.generate_person_session_token(person)
      conn = PersonAuth.fetch_current_person(conn, [])
      refute get_session(conn, :person_token)
      refute conn.assigns.current_person
    end
  end

  describe "on_mount: mount_current_person" do
    test "assigns current_person based on a valid person_token ", %{conn: conn, person: person} do
      person_token = Accounts.generate_person_session_token(person)
      session = conn |> put_session(:person_token, person_token) |> get_session()

      {:cont, updated_socket} =
        PersonAuth.on_mount(:mount_current_person, %{}, session, %LiveView.Socket{})

      assert updated_socket.assigns.current_person.id == person.id
    end

    test "assigns nil to current_person assign if there isn't a valid person_token ", %{conn: conn} do
      person_token = "invalid_token"
      session = conn |> put_session(:person_token, person_token) |> get_session()

      {:cont, updated_socket} =
        PersonAuth.on_mount(:mount_current_person, %{}, session, %LiveView.Socket{})

      assert updated_socket.assigns.current_person == nil
    end

    test "assigns nil to current_person assign if there isn't a person_token", %{conn: conn} do
      session = conn |> get_session()

      {:cont, updated_socket} =
        PersonAuth.on_mount(:mount_current_person, %{}, session, %LiveView.Socket{})

      assert updated_socket.assigns.current_person == nil
    end
  end

  describe "on_mount: ensure_authenticated" do
    test "authenticates current_person based on a valid person_token ", %{conn: conn, person: person} do
      person_token = Accounts.generate_person_session_token(person)
      session = conn |> put_session(:person_token, person_token) |> get_session()

      {:cont, updated_socket} =
        PersonAuth.on_mount(:ensure_authenticated, %{}, session, %LiveView.Socket{})

      assert updated_socket.assigns.current_person.id == person.id
    end

    test "redirects to login page if there isn't a valid person_token ", %{conn: conn} do
      person_token = "invalid_token"
      session = conn |> put_session(:person_token, person_token) |> get_session()

      socket = %LiveView.Socket{
        endpoint: AuthWeb.Endpoint,
        assigns: %{__changed__: %{}, flash: %{}}
      }

      {:halt, updated_socket} = PersonAuth.on_mount(:ensure_authenticated, %{}, session, socket)
      assert updated_socket.assigns.current_person == nil
    end

    test "redirects to login page if there isn't a person_token ", %{conn: conn} do
      session = conn |> get_session()

      socket = %LiveView.Socket{
        endpoint: AuthWeb.Endpoint,
        assigns: %{__changed__: %{}, flash: %{}}
      }

      {:halt, updated_socket} = PersonAuth.on_mount(:ensure_authenticated, %{}, session, socket)
      assert updated_socket.assigns.current_person == nil
    end
  end

  describe "on_mount: :redirect_if_person_is_authenticated" do
    test "redirects if there is an authenticated  person ", %{conn: conn, person: person} do
      person_token = Accounts.generate_person_session_token(person)
      session = conn |> put_session(:person_token, person_token) |> get_session()

      assert {:halt, _updated_socket} =
               PersonAuth.on_mount(
                 :redirect_if_person_is_authenticated,
                 %{},
                 session,
                 %LiveView.Socket{}
               )
    end

    test "Don't redirect is there is no authenticated person", %{conn: conn} do
      session = conn |> get_session()

      assert {:cont, _updated_socket} =
               PersonAuth.on_mount(
                 :redirect_if_person_is_authenticated,
                 %{},
                 session,
                 %LiveView.Socket{}
               )
    end
  end

  describe "redirect_if_person_is_authenticated/2" do
    test "redirects if person is authenticated", %{conn: conn, person: person} do
      conn = conn |> assign(:current_person, person) |> PersonAuth.redirect_if_person_is_authenticated([])
      assert conn.halted
      assert redirected_to(conn) == ~p"/"
    end

    test "does not redirect if person is not authenticated", %{conn: conn} do
      conn = PersonAuth.redirect_if_person_is_authenticated(conn, [])
      refute conn.halted
      refute conn.status
    end
  end

  describe "require_authenticated_person/2" do
    test "redirects if person is not authenticated", %{conn: conn} do
      conn = conn |> fetch_flash() |> PersonAuth.require_authenticated_person([])
      assert conn.halted

      assert redirected_to(conn) == ~p"/people/log_in"

      assert Phoenix.Flash.get(conn.assigns.flash, :error) ==
               "You must log in to access this page."
    end

    test "stores the path to redirect to on GET", %{conn: conn} do
      halted_conn =
        %{conn | path_info: ["foo"], query_string: ""}
        |> fetch_flash()
        |> PersonAuth.require_authenticated_person([])

      assert halted_conn.halted
      assert get_session(halted_conn, :person_return_to) == "/foo"

      halted_conn =
        %{conn | path_info: ["foo"], query_string: "bar=baz"}
        |> fetch_flash()
        |> PersonAuth.require_authenticated_person([])

      assert halted_conn.halted
      assert get_session(halted_conn, :person_return_to) == "/foo?bar=baz"

      halted_conn =
        %{conn | path_info: ["foo"], query_string: "bar", method: "POST"}
        |> fetch_flash()
        |> PersonAuth.require_authenticated_person([])

      assert halted_conn.halted
      refute get_session(halted_conn, :person_return_to)
    end

    test "does not redirect if person is authenticated", %{conn: conn, person: person} do
      conn = conn |> assign(:current_person, person) |> PersonAuth.require_authenticated_person([])
      refute conn.halted
      refute conn.status
    end
  end
end
