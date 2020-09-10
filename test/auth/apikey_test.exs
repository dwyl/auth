defmodule Auth.ApikeyTest do
  use Auth.DataCase
  # use AuthWeb.ConnCase
  use ExUnitProperties
  # alias Auth.Apikey
  @email System.get_env("ADMIN_EMAIL")

  describe "Create an AUTH_API_KEY for a given person_id" do
    test "encrypt_encode/1 returns a base58 we can decrypt" do
      person_id = 1
      key = Auth.Apikey.encrypt_encode(person_id)

      decrypted =
        key
        |> Base58.decode()
        |> Fields.AES.decrypt()
        |> String.to_integer()

      assert decrypted == person_id
    end

    test "decode_decrypt/1 reverses the operation of encrypt_encode/1" do
      person_id = 4_869_234_521
      key = Auth.Apikey.encrypt_encode(person_id)
      id = Auth.Apikey.decode_decrypt(key)
      assert person_id == id
    end

    test "create_api_key/1 creates an AUTH_API_KEY" do
      person_id = 123_456_789
      key = Auth.Apikey.create_api_key(person_id)
      assert key =~ "/"
      # parts = String.split(key, "/")
      # assert decode_decrypt(List.first(parts)) == person_id
    end

    test "decrypt_api_key/1 decrypts an AUTH_API_KEY" do
      person_id = 1234
      key = Auth.Apikey.create_api_key(person_id)
      decrypted = Auth.Apikey.decrypt_api_key(key)
      assert decrypted == person_id
    end

    test "decode_decrypt/1 with invalid client_id" do
      valid_key = Auth.Apikey.encrypt_encode(1)
      person_id = Auth.Apikey.decode_decrypt(valid_key)
      assert person_id == 1

      invalid_key = String.slice(valid_key, 0..-2)
      error = Auth.Apikey.decode_decrypt(invalid_key)
      assert error == 0
    end

    property "Check a batch of int values can be decoded decode_decrypt/1" do
      check all(int <- integer()) do
        assert Auth.Apikey.decode_decrypt(
                 Auth.Apikey.encrypt_encode(int)
               ) == int
      end
    end
  end

  test "list_apikeys_for_person/1 returns all apikeys person" do
    person = Auth.Person.get_person_by_email(@email)

    keys = Auth.Apikey.list_apikeys_for_person(person.id)
    assert length(keys) == 1

    # Insert Another App (And API Key):
    Auth.App.create_app(%{
      "name" => "My Amazing Key",
      "url" => "http://localhost:400",
      "person_id" => person.id
    })

    keys = Auth.Apikey.list_apikeys_for_person(person.id)
    assert length(keys) == 2
  end
end
