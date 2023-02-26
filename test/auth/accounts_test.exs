defmodule Auth.AccountsTest do
  use Auth.DataCase

  alias Auth.Accounts

  import Auth.AccountsFixtures
  alias Auth.Accounts.{Person, PersonToken}

  describe "get_person_by_email/1" do
    test "does not return the person if the email does not exist" do
      refute Accounts.get_person_by_email("unknown@example.com")
    end

    test "returns the person if the email exists" do
      %{id: id} = person = person_fixture()
      assert %Person{id: ^id} = Accounts.get_person_by_email(person.email)
    end
  end

  describe "get_person_by_email_and_password/2" do
    test "does not return the person if the email does not exist" do
      refute Accounts.get_person_by_email_and_password("unknown@example.com", "hello world!")
    end

    test "does not return the person if the password is not valid" do
      person = person_fixture()
      refute Accounts.get_person_by_email_and_password(person.email, "invalid")
    end

    test "returns the person if the email and password are valid" do
      %{id: id} = person = person_fixture()

      assert %Person{id: ^id} =
               Accounts.get_person_by_email_and_password(person.email, valid_person_password())
    end
  end

  describe "get_person!/1" do
    test "raises if id is invalid" do
      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_person!(-1)
      end
    end

    test "returns the person with the given id" do
      %{id: id} = person = person_fixture()
      assert %Person{id: ^id} = Accounts.get_person!(person.id)
    end
  end

  describe "register_person/1" do
    test "requires email and password to be set" do
      {:error, changeset} = Accounts.register_person(%{})

      assert %{
               password: ["can't be blank"],
               email: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "validates email and password when given" do
      {:error, changeset} = Accounts.register_person(%{email: "not valid", password: "not valid"})

      assert %{
               email: ["must have the @ sign and no spaces"],
               password: ["should be at least 12 character(s)"]
             } = errors_on(changeset)
    end

    test "validates maximum values for email and password for security" do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Accounts.register_person(%{email: too_long, password: too_long})
      assert "should be at most 160 character(s)" in errors_on(changeset).email
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates email uniqueness" do
      %{email: email} = person_fixture()
      {:error, changeset} = Accounts.register_person(%{email: email})
      assert "has already been taken" in errors_on(changeset).email

      # Now try with the upper cased email too, to check that email case is ignored.
      {:error, changeset} = Accounts.register_person(%{email: String.upcase(email)})
      assert "has already been taken" in errors_on(changeset).email
    end

    test "registers people with a hashed password" do
      email = unique_person_email()
      {:ok, person} = Accounts.register_person(valid_person_attributes(email: email))
      assert person.email == email
      assert is_binary(person.hashed_password)
      assert is_nil(person.confirmed_at)
      assert is_nil(person.password)
    end
  end

  describe "change_person_registration/2" do
    test "returns a changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_person_registration(%Person{})
      assert changeset.required == [:password, :email]
    end

    test "allows fields to be set" do
      email = unique_person_email()
      password = valid_person_password()

      changeset =
        Accounts.change_person_registration(
          %Person{},
          valid_person_attributes(email: email, password: password)
        )

      assert changeset.valid?
      assert get_change(changeset, :email) == email
      assert get_change(changeset, :password) == password
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "change_person_email/2" do
    test "returns a person changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_person_email(%Person{})
      assert changeset.required == [:email]
    end
  end

  describe "apply_person_email/3" do
    setup do
      %{person: person_fixture()}
    end

    test "requires email to change", %{person: person} do
      {:error, changeset} = Accounts.apply_person_email(person, valid_person_password(), %{})
      assert %{email: ["did not change"]} = errors_on(changeset)
    end

    test "validates email", %{person: person} do
      {:error, changeset} =
        Accounts.apply_person_email(person, valid_person_password(), %{email: "not valid"})

      assert %{email: ["must have the @ sign and no spaces"]} = errors_on(changeset)
    end

    test "validates maximum value for email for security", %{person: person} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Accounts.apply_person_email(person, valid_person_password(), %{email: too_long})

      assert "should be at most 160 character(s)" in errors_on(changeset).email
    end

    test "validates email uniqueness", %{person: person} do
      %{email: email} = person_fixture()
      password = valid_person_password()

      {:error, changeset} = Accounts.apply_person_email(person, password, %{email: email})

      assert "has already been taken" in errors_on(changeset).email
    end

    test "validates current password", %{person: person} do
      {:error, changeset} =
        Accounts.apply_person_email(person, "invalid", %{email: unique_person_email()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "applies the email without persisting it", %{person: person} do
      email = unique_person_email()
      {:ok, person} = Accounts.apply_person_email(person, valid_person_password(), %{email: email})
      assert person.email == email
      assert Accounts.get_person!(person.id).email != email
    end
  end

  describe "deliver_person_update_email_instructions/3" do
    setup do
      %{person: person_fixture()}
    end

    test "sends token through notification", %{person: person} do
      token =
        extract_person_token(fn url ->
          Accounts.deliver_person_update_email_instructions(person, "current@example.com", url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert person_token = Repo.get_by(PersonToken, token: :crypto.hash(:sha256, token))
      assert person_token.person_id == person.id
      assert person_token.sent_to == person.email
      assert person_token.context == "change:current@example.com"
    end
  end

  describe "update_person_email/2" do
    setup do
      person = person_fixture()
      email = unique_person_email()

      token =
        extract_person_token(fn url ->
          Accounts.deliver_person_update_email_instructions(%{person | email: email}, person.email, url)
        end)

      %{person: person, token: token, email: email}
    end

    test "updates the email with a valid token", %{person: person, token: token, email: email} do
      assert Accounts.update_person_email(person, token) == :ok
      changed_person = Repo.get!(Person, person.id)
      assert changed_person.email != person.email
      assert changed_person.email == email
      assert changed_person.confirmed_at
      assert changed_person.confirmed_at != person.confirmed_at
      refute Repo.get_by(PersonToken, person_id: person.id)
    end

    test "does not update email with invalid token", %{person: person} do
      assert Accounts.update_person_email(person, "oops") == :error
      assert Repo.get!(Person, person.id).email == person.email
      assert Repo.get_by(PersonToken, person_id: person.id)
    end

    test "does not update email if person email changed", %{person: person, token: token} do
      assert Accounts.update_person_email(%{person | email: "current@example.com"}, token) == :error
      assert Repo.get!(Person, person.id).email == person.email
      assert Repo.get_by(PersonToken, person_id: person.id)
    end

    test "does not update email if token expired", %{person: person, token: token} do
      {1, nil} = Repo.update_all(PersonToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Accounts.update_person_email(person, token) == :error
      assert Repo.get!(Person, person.id).email == person.email
      assert Repo.get_by(PersonToken, person_id: person.id)
    end
  end

  describe "change_person_password/2" do
    test "returns a person changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_person_password(%Person{})
      assert changeset.required == [:password]
    end

    test "allows fields to be set" do
      changeset =
        Accounts.change_person_password(%Person{}, %{
          "password" => "new valid password"
        })

      assert changeset.valid?
      assert get_change(changeset, :password) == "new valid password"
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "update_person_password/3" do
    setup do
      %{person: person_fixture()}
    end

    test "validates password", %{person: person} do
      {:error, changeset} =
        Accounts.update_person_password(person, valid_person_password(), %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{person: person} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Accounts.update_person_password(person, valid_person_password(), %{password: too_long})

      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates current password", %{person: person} do
      {:error, changeset} =
        Accounts.update_person_password(person, "invalid", %{password: valid_person_password()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "updates the password", %{person: person} do
      {:ok, person} =
        Accounts.update_person_password(person, valid_person_password(), %{
          password: "new valid password"
        })

      assert is_nil(person.password)
      assert Accounts.get_person_by_email_and_password(person.email, "new valid password")
    end

    test "deletes all tokens for the given person", %{person: person} do
      _ = Accounts.generate_person_session_token(person)

      {:ok, _} =
        Accounts.update_person_password(person, valid_person_password(), %{
          password: "new valid password"
        })

      refute Repo.get_by(PersonToken, person_id: person.id)
    end
  end

  describe "generate_person_session_token/1" do
    setup do
      %{person: person_fixture()}
    end

    test "generates a token", %{person: person} do
      token = Accounts.generate_person_session_token(person)
      assert person_token = Repo.get_by(PersonToken, token: token)
      assert person_token.context == "session"

      # Creating the same token for another person should fail
      assert_raise Ecto.ConstraintError, fn ->
        Repo.insert!(%PersonToken{
          token: person_token.token,
          person_id: person_fixture().id,
          context: "session"
        })
      end
    end
  end

  describe "get_person_by_session_token/1" do
    setup do
      person = person_fixture()
      token = Accounts.generate_person_session_token(person)
      %{person: person, token: token}
    end

    test "returns person by token", %{person: person, token: token} do
      assert session_person = Accounts.get_person_by_session_token(token)
      assert session_person.id == person.id
    end

    test "does not return person for invalid token" do
      refute Accounts.get_person_by_session_token("oops")
    end

    test "does not return person for expired token", %{token: token} do
      {1, nil} = Repo.update_all(PersonToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Accounts.get_person_by_session_token(token)
    end
  end

  describe "delete_person_session_token/1" do
    test "deletes the token" do
      person = person_fixture()
      token = Accounts.generate_person_session_token(person)
      assert Accounts.delete_person_session_token(token) == :ok
      refute Accounts.get_person_by_session_token(token)
    end
  end

  describe "deliver_person_confirmation_instructions/2" do
    setup do
      %{person: person_fixture()}
    end

    test "sends token through notification", %{person: person} do
      token =
        extract_person_token(fn url ->
          Accounts.deliver_person_confirmation_instructions(person, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert person_token = Repo.get_by(PersonToken, token: :crypto.hash(:sha256, token))
      assert person_token.person_id == person.id
      assert person_token.sent_to == person.email
      assert person_token.context == "confirm"
    end
  end

  describe "confirm_person/1" do
    setup do
      person = person_fixture()

      token =
        extract_person_token(fn url ->
          Accounts.deliver_person_confirmation_instructions(person, url)
        end)

      %{person: person, token: token}
    end

    test "confirms the email with a valid token", %{person: person, token: token} do
      assert {:ok, confirmed_person} = Accounts.confirm_person(token)
      assert confirmed_person.confirmed_at
      assert confirmed_person.confirmed_at != person.confirmed_at
      assert Repo.get!(Person, person.id).confirmed_at
      refute Repo.get_by(PersonToken, person_id: person.id)
    end

    test "does not confirm with invalid token", %{person: person} do
      assert Accounts.confirm_person("oops") == :error
      refute Repo.get!(Person, person.id).confirmed_at
      assert Repo.get_by(PersonToken, person_id: person.id)
    end

    test "does not confirm email if token expired", %{person: person, token: token} do
      {1, nil} = Repo.update_all(PersonToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Accounts.confirm_person(token) == :error
      refute Repo.get!(Person, person.id).confirmed_at
      assert Repo.get_by(PersonToken, person_id: person.id)
    end
  end

  describe "deliver_person_reset_password_instructions/2" do
    setup do
      %{person: person_fixture()}
    end

    test "sends token through notification", %{person: person} do
      token =
        extract_person_token(fn url ->
          Accounts.deliver_person_reset_password_instructions(person, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert person_token = Repo.get_by(PersonToken, token: :crypto.hash(:sha256, token))
      assert person_token.person_id == person.id
      assert person_token.sent_to == person.email
      assert person_token.context == "reset_password"
    end
  end

  describe "get_person_by_reset_password_token/1" do
    setup do
      person = person_fixture()

      token =
        extract_person_token(fn url ->
          Accounts.deliver_person_reset_password_instructions(person, url)
        end)

      %{person: person, token: token}
    end

    test "returns the person with valid token", %{person: %{id: id}, token: token} do
      assert %Person{id: ^id} = Accounts.get_person_by_reset_password_token(token)
      assert Repo.get_by(PersonToken, person_id: id)
    end

    test "does not return the person with invalid token", %{person: person} do
      refute Accounts.get_person_by_reset_password_token("oops")
      assert Repo.get_by(PersonToken, person_id: person.id)
    end

    test "does not return the person if token expired", %{person: person, token: token} do
      {1, nil} = Repo.update_all(PersonToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Accounts.get_person_by_reset_password_token(token)
      assert Repo.get_by(PersonToken, person_id: person.id)
    end
  end

  describe "reset_person_password/2" do
    setup do
      %{person: person_fixture()}
    end

    test "validates password", %{person: person} do
      {:error, changeset} =
        Accounts.reset_person_password(person, %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{person: person} do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Accounts.reset_person_password(person, %{password: too_long})
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "updates the password", %{person: person} do
      {:ok, updated_person} = Accounts.reset_person_password(person, %{password: "new valid password"})
      assert is_nil(updated_person.password)
      assert Accounts.get_person_by_email_and_password(person.email, "new valid password")
    end

    test "deletes all tokens for the given person", %{person: person} do
      _ = Accounts.generate_person_session_token(person)
      {:ok, _} = Accounts.reset_person_password(person, %{password: "new valid password"})
      refute Repo.get_by(PersonToken, person_id: person.id)
    end
  end

  describe "inspect/2 for the Person module" do
    test "does not include password" do
      refute inspect(%Person{password: "123456"}) =~ "password: \"123456\""
    end
  end
end
