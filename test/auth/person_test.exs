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
end
