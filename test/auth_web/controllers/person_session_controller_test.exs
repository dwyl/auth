defmodule AuthWeb.PersonSessionControllerTest do
  use AuthWeb.ConnCase, async: true

  import Auth.AccountsFixtures

  setup do
    %{person: person_fixture()}
  end

  describe "GET /people/log_in" do
    test "renders log in page", %{conn: conn} do
      conn = get(conn, ~p"/people/log_in")
      response = html_response(conn, 200)
      assert response =~ "Log in"
      assert response =~ ~p"/users/register"
      assert response =~ "Forgot your password?"
    end

    test "redirects if already logged in", %{conn: conn, person: person} do
      conn = conn |> log_in_person(person) |> get(~p"/people/log_in")
      assert redirected_to(conn) == ~p"/"
    end
  end

  describe "POST /people/log_in" do
    test "logs the person in", %{conn: conn, person: person} do
      conn =
        post(conn, ~p"/people/log_in", %{
          "person" => %{"email" => person.email, "password" => valid_person_password()}
        })

      assert get_session(conn, :person_token)
      assert redirected_to(conn) == ~p"/"

      # Now do a logged in request and assert on the menu
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      assert response =~ person.email
      assert response =~ ~p"/users/settings"
      assert response =~ ~p"/users/log_out"
    end

    test "logs the person in with remember me", %{conn: conn, person: person} do
      conn =
        post(conn, ~p"/people/log_in", %{
          "person" => %{
            "email" => person.email,
            "password" => valid_person_password(),
            "remember_me" => "true"
          }
        })

      assert conn.resp_cookies["_auth_web_person_remember_me"]
      assert redirected_to(conn) == ~p"/"
    end

    test "logs the person in with return to", %{conn: conn, person: person} do
      conn =
        conn
        |> init_test_session(person_return_to: "/foo/bar")
        |> post(~p"/people/log_in", %{
          "person" => %{
            "email" => person.email,
            "password" => valid_person_password()
          }
        })

      assert redirected_to(conn) == "/foo/bar"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Welcome back!"
    end

    test "emits error message with invalid credentials", %{conn: conn, person: person} do
      conn =
        post(conn, ~p"/people/log_in", %{
          "person" => %{"email" => person.email, "password" => "invalid_password"}
        })

      response = html_response(conn, 200)
      assert response =~ "Log in"
      assert response =~ "Invalid email or password"
    end
  end

  describe "DELETE /people/log_out" do
    test "logs the person out", %{conn: conn, person: person} do
      conn = conn |> log_in_person(person) |> delete(~p"/people/log_out")
      assert redirected_to(conn) == ~p"/"
      refute get_session(conn, :person_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Logged out successfully"
    end

    test "succeeds even if the person is not logged in", %{conn: conn} do
      conn = delete(conn, ~p"/people/log_out")
      assert redirected_to(conn) == ~p"/"
      refute get_session(conn, :person_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Logged out successfully"
    end
  end
end
