defmodule AuthWeb.PersonResetPasswordControllerTest do
  use AuthWeb.ConnCase, async: true

  alias Auth.Accounts
  alias Auth.Repo
  import Auth.AccountsFixtures

  setup do
    %{person: person_fixture()}
  end

  describe "GET /people/reset_password" do
    test "renders the reset password page", %{conn: conn} do
      conn = get(conn, ~p"/people/reset_password")
      response = html_response(conn, 200)
      assert response =~ "Forgot your password?"
    end
  end

  describe "POST /people/reset_password" do
    @tag :capture_log
    test "sends a new reset password token", %{conn: conn, person: person} do
      conn =
        post(conn, ~p"/people/reset_password", %{
          "person" => %{"email" => person.email}
        })

      assert redirected_to(conn) == ~p"/"

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "If your email is in our system"

      assert Repo.get_by!(Accounts.PersonToken, person_id: person.id).context == "reset_password"
    end

    test "does not send reset password token if email is invalid", %{conn: conn} do
      conn =
        post(conn, ~p"/people/reset_password", %{
          "person" => %{"email" => "unknown@example.com"}
        })

      assert redirected_to(conn) == ~p"/"

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "If your email is in our system"

      assert Repo.all(Accounts.PersonToken) == []
    end
  end

  # describe "GET /people/reset_password/:token" do
  #   setup %{person: person} do
  #     token =
  #       extract_person_token(fn url ->
  #         Accounts.deliver_person_reset_password_instructions(person, url)
  #       end)

  #     %{token: token}
  #   end

  #   test "renders reset password", %{conn: conn, token: token} do
  #     conn = get(conn, ~p"/people/reset_password/#{token}")
  #     assert html_response(conn, 200) =~ "Reset password"
  #   end

  #   test "does not render reset password with invalid token", %{conn: conn} do
  #     conn = get(conn, ~p"/people/reset_password/oops")
  #     assert redirected_to(conn) == ~p"/"

  #     assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
  #              "Reset password link is invalid or it has expired"
  #   end
  # end

  describe "PUT /people/reset_password/:token" do
    setup %{person: person} do
      token =
        extract_person_token(fn url ->
          Accounts.deliver_person_reset_password_instructions(person, url)
        end)

      %{token: token}
    end

    # test "resets password once", %{conn: conn, person: person, token: token} do
    #   conn =
    #     put(conn, ~p"/people/reset_password/#{token}", %{
    #       "person" => %{
    #         "password" => "new valid password",
    #         "password_confirmation" => "new valid password"
    #       }
    #     })

    #   assert redirected_to(conn) == ~p"/people/log_in"
    #   refute get_session(conn, :person_token)

    #   assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
    #            "Password reset successfully"

    #   assert Accounts.get_person_by_email_and_password(person.email, "new valid password")
    # end

    # test "does not reset password on invalid data", %{conn: conn, token: token} do
    #   conn =
    #     put(conn, ~p"/people/reset_password/#{token}", %{
    #       "person" => %{
    #         "password" => "too short",
    #         "password_confirmation" => "does not match"
    #       }
    #     })

    #   assert html_response(conn, 200) =~ "something went wrong"
    # end

    # test "does not reset password with invalid token", %{conn: conn} do
    #   conn = put(conn, ~p"/people/reset_password/oops")
    #   assert redirected_to(conn) == ~p"/"

    #   assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
    #            "Reset password link is invalid or it has expired"
    # end
  end
end
