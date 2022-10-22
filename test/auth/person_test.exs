defmodule Auth.PersonTest do
  use Auth.DataCase, async: true
  alias Auth.{Person}

  test "create_person/1" do
    alex = %{email: "alex@gmail.com", auth_provider: "email"}
    person = Person.create_person(alex)
    assert person.id > 1

    # attempt to recreate alex (just returns existing record):
    person2 = Person.create_person(alex)
    assert person2.id == person.id
  end

  test "verify_person_by_id/1" do
    alice = %{email: "alice@mail.com", auth_provider: "email"}
    person = Person.create_person(alice)
    assert is_nil(person.status)

    Person.verify_person_by_id(person.id)
    updated_person = Person.get_person_by_id(person.id)
    assert updated_person.status == 1
  end

  test "Auth.Person.decrypt_email/1" do
    email = "alex@gmail.com"
    encrypted = email |> Fields.AES.encrypt() |> Base58.encode()
    decrypted = Person.decrypt_email(encrypted)
    assert email == decrypted

    # Unhappy ("rescue") path:
    invalid_email = ""
    assert Person.decrypt_email(invalid_email) == 0
  end
end
