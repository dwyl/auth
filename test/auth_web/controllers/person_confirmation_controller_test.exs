defmodule AuthWeb.PersonConfirmationControllerTest do
  use AuthWeb.ConnCase, async: true

  alias Auth.Accounts
  alias Auth.Repo
  import Auth.AccountsFixtures

  setup do
    %{person: person_fixture()}
  end

  describe "GET /people/confirm" do
    test "renders the resend confirmation page", %{conn: conn} do
      conn = get(conn, ~p"/people/confirm")
      response = html_response(conn, 200)
      assert response =~ "Resend confirmation instructions"
    end
  end

  describe "POST /people/confirm" do
    @tag :capture_log
    test "sends a new confirmation token", %{conn: conn, person: person} do
      conn =
        post(conn, ~p"/people/confirm", %{
          "person" => %{"email" => person.email}
        })

      assert redirected_to(conn) == ~p"/"

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "If your email is in our system"

      assert Repo.get_by!(Accounts.PersonToken, person_id: person.id).context == "confirm"
    end

    test "does not send confirmation token if Person is confirmed", %{conn: conn, person: person} do
      Repo.update!(Accounts.Person.confirm_changeset(person))

      conn =
        post(conn, ~p"/people/confirm", %{
          "person" => %{"email" => person.email}
        })

      assert redirected_to(conn) == ~p"/"

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "If your email is in our system"

      refute Repo.get_by(Accounts.PersonToken, person_id: person.id)
    end

    test "does not send confirmation token if email is invalid", %{conn: conn} do
      conn =
        post(conn, ~p"/people/confirm", %{
          "person" => %{"email" => "unknown@example.com"}
        })

      assert redirected_to(conn) == ~p"/"

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "If your email is in our system"

      assert Repo.all(Accounts.PersonToken) == []
    end
  end

  describe "GET /people/confirm/:token" do
    test "renders the confirmation page", %{conn: conn} do
      token_path = ~p"/people/confirm/some-token"
      conn = get(conn, token_path)
      response = html_response(conn, 200)
      assert response =~ "Confirm account"

      assert response =~ "action=\"#{token_path}\""
    end
  end

  # describe "POST /people/confirm/:token" do
  #   test "confirms the given token once", %{conn: conn, person: person} do
  #     token =
  #       extract_person_token(fn url ->
  #         Accounts.deliver_person_confirmation_instructions(person, url)
  #       end)

  #     conn = post(conn, ~p"/people/confirm/#{token}")
  #     assert redirected_to(conn) == ~p"/"

  #     assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
  #              "Person confirmed successfully"

  #     assert Accounts.get_person!(person.id).confirmed_at
  #     refute get_session(conn, :person_token)
  #     assert Repo.all(Accounts.PersonToken) == []

  #     # When not logged in
  #     conn = post(conn, ~p"/people/confirm/#{token}")
  #     assert redirected_to(conn) == ~p"/"

  #     assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
  #              "Person confirmation link is invalid or it has expired"

  #     # When logged in
  #     conn =
  #       build_conn()
  #       |> log_in_person(person)
  #       |> post(~p"/people/confirm/#{token}")

  #     assert redirected_to(conn) == ~p"/"
  #     refute Phoenix.Flash.get(conn.assigns.flash, :error)
  #   end

  #   test "does not confirm email with invalid token", %{conn: conn, person: person} do
  #     conn = post(conn, ~p"/people/confirm/oops")
  #     assert redirected_to(conn) == ~p"/"

  #     assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
  #              "Person confirmation link is invalid or it has expired"

  #     refute Accounts.get_person!(person.id).confirmed_at
  #   end
  # end
end
