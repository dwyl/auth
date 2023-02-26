defmodule AuthWeb.PersonRegistrationControllerTest do
  use AuthWeb.ConnCase, async: true

  import Auth.AccountsFixtures

  describe "GET /people/register" do
    test "renders registration page", %{conn: conn} do
      conn = get(conn, ~p"/people/register")
      response = html_response(conn, 200)
      assert response =~ "Register"
      assert response =~ ~p"/users/log_in"
      assert response =~ ~p"/users/register"
    end

    test "redirects if already logged in", %{conn: conn} do
      conn = conn |> log_in_person(person_fixture()) |> get(~p"/people/register")

      assert redirected_to(conn) == ~p"/"
    end
  end

  describe "POST /people/register" do
    @tag :capture_log
    test "creates account and logs the person in", %{conn: conn} do
      email = unique_person_email()

      conn =
        post(conn, ~p"/people/register", %{
          "person" => valid_person_attributes(email: email)
        })

      assert get_session(conn, :person_token)
      assert redirected_to(conn) == ~p"/"

      # Now do a logged in request and assert on the menu
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      assert response =~ email
      assert response =~ ~p"/users/settings"
      assert response =~ ~p"/users/log_out"
    end

    test "render errors for invalid data", %{conn: conn} do
      conn =
        post(conn, ~p"/people/register", %{
          "person" => %{"email" => "with spaces", "password" => "too short"}
        })

      response = html_response(conn, 200)
      assert response =~ "Register"
      assert response =~ "must have the @ sign and no spaces"
      assert response =~ "should be at least 12 character"
    end
  end
end
