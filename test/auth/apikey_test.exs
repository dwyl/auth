defmodule Auth.ApikeyTest do
  use Auth.DataCase, async: true
  use ExUnitProperties

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
      app_id = 4_869_234_521
      key = Auth.Apikey.encrypt_encode(app_id)
      {:ok, id} = Auth.Apikey.decode_decrypt(key)
      assert app_id == id
    end

    test "decode_decrypt/1 with invalid client_id" do
      valid_key = Auth.Apikey.encrypt_encode(1)
      {:ok, app_id} = Auth.Apikey.decode_decrypt(valid_key)
      assert app_id == 1

      invalid_key = String.slice(valid_key, 0..-2)

      {err, _} = Auth.Apikey.decode_decrypt(invalid_key)
      assert :error == err
    end

    property "Check a batch of int values can be decoded decode_decrypt/1" do
      check all(int <- integer()) do
        assert Auth.Apikey.decode_decrypt(Auth.Apikey.encrypt_encode(int)) == {:ok, int}
      end
    end
  end
end
