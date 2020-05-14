defmodule Auth.ApikeyTest do
  # use Auth.DataCase
  use AuthWeb.ConnCase
  # alias Auth.Apikey
  @email System.get_env("ADMIN_EMAIL")

  test "list_apikeys_for_person/1 returns all apikeys person" do
    person = Auth.Person.get_person_by_email(@email)
    # IO.inspect(person, label: "person")

    keys = Auth.Apikey.list_apikeys_for_person(person.id)
    # IO.inspect(keys, label: "keys")
    assert length(keys) == 1

    # Insert Two API keys:
    params = %{
      # "description" => "test key",
      "name" => "My Amazing Key",
      "url" => "http://localhost:400",
      "person_id" => person.id,
      "client_secret" => AuthWeb.ApikeyController.encrypt_encode(person.id)
    }

    Auth.Apikey.create_apikey(params)

    Map.merge(params, %{
      "client_secret" => AuthWeb.ApikeyController.encrypt_encode(person.id)
    })
    |> Auth.Apikey.create_apikey()

    keys = Auth.Apikey.list_apikeys_for_person(person.id)
    assert length(keys) == 3
  end
end
