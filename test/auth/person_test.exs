defmodule Auth.PersonTest do
  use Auth.DataCase
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
    alice = %{email: "alice@gmail.com", auth_provider: "email"}
    person = Person.create_person(alice)
    assert is_nil(person.status)

    Person.verify_person_by_id(person.id)
    updated_person = Person.get_person_by_id(person.id)
    assert updated_person.status == 1
  end
end
