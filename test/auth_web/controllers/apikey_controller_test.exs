defmodule AuthWeb.ApikeyControllerTest do
  use AuthWeb.ConnCase
  use ExUnitProperties

  # alias Auth.Apikey
  import AuthWeb.ApikeyController
  @email System.get_env("ADMIN_EMAIL")

  describe "Create a DWYL_API_KEY for a given person_id" do
    test "encrypt_encode/1 returns a base58 we can decrypt" do
      person_id = 1
      key = encrypt_encode(person_id)
      # |> IO.inspect(label: "key")

      decrypted = key
      |> Base58.decode
      # |> IO.inspect(label: "decoded")
      |> Fields.AES.decrypt()
      # |> IO.inspect(label: "decrypted")
      |> String.to_integer()
      # |> IO.inspect(label: "int")

      assert decrypted == person_id
    end

    test "decode_decrypt/1 reverses the operation of encrypt_encode/1" do
      person_id = 4869234521
      key = encrypt_encode(person_id)
      id = decode_decrypt(key)
      assert person_id == id
    end

    test "create_api_key/1 creates a DWYL_API_KEY" do
      person_id = 123456789
      key = create_api_key(person_id)
      assert key =~ "/"
    end

    test "decrypt_api_key/1 decrypts a DWYL_API_KEY" do
      person_id = 1234
      key = create_api_key(person_id) # |> IO.inspect()
      # IO.inspect(String.length(key), label: "String.length(key)")
      decrypted = decrypt_api_key(key) # |> IO.inspect()
      assert decrypted == person_id
    end

    test "decode_decrypt/1 with invalid client_id" do
      valid_key = AuthWeb.ApikeyController.encrypt_encode(1)
      person_id = AuthWeb.ApikeyController.decode_decrypt(valid_key)
      assert person_id == 1

      invalid_key = String.slice(valid_key, 0..-2)
      error = AuthWeb.ApikeyController.decode_decrypt(invalid_key)
      assert error == 0
    end

    property "Check a batch of int values can be decoded decode_decrypt/1" do
      check all(int <- integer()) do
        assert decode_decrypt(encrypt_encode(int)) == int
      end
    end
  end



  @create_attrs %{description: "some description", name: "some name", url: "some url"}
  # @update_attrs %{client_secret: "some updated client_secret", description: "some updated description", key_id: 43, name: "some updated name", url: "surl"}
  # @invalid_attrs %{client_secret: nil, description: nil, key_id: nil, name: nil, url: nil}
  #
  # def fixture(:apikey) do
  #   {:ok, apikey} = Ctx.create_apikey(@create_attrs)
  #   apikey
  # end
  #
  describe "index" do
    test "lists all apikeys", %{conn: conn} do
      person = Auth.Person.get_person_by_email(@email)
      conn = AuthPlug.create_jwt_session(conn, %{email: @email, id: person.id})
      conn = get(conn, Routes.apikey_path(conn, :index))
      assert html_response(conn, 200) =~ "DWYL_API_KEY"
    end
  end

  describe "new apikey" do
    test "renders form", %{conn: conn} do
      person = Auth.Person.get_person_by_email(@email)
      conn = AuthPlug.create_jwt_session(conn, %{email: @email, id: person.id})

      conn = get(conn, Routes.apikey_path(conn, :new))
      assert html_response(conn, 200) =~ "New Apikey"
    end
  end

  describe "create apikey" do

    test "redirects to show when data is valid", %{conn: conn} do
      person = Auth.Person.get_person_by_email(@email)
      conn = AuthPlug.create_jwt_session(conn, %{email: @email, id: person.id})

      conn = post(conn, Routes.apikey_path(conn, :create), apikey: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.apikey_path(conn, :show, id)

      conn = get(conn, Routes.apikey_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Your DWYL_API_KEY"
    end

    # test "renders errors when data is invalid", %{conn: conn} do
    #   person = Auth.Person.get_person_by_email(@email)
    #   conn = AuthPlug.create_jwt_session(conn, %{email: @email, id: person.id})
    #
    #   conn = post(conn, Routes.apikey_path(conn, :create), apikey: @invalid_attrs)
    #   assert html_response(conn, 200) =~ "New Apikey"
    # end
  end
  #
  # describe "edit apikey" do
  #   setup [:create_apikey]
  #
  #   test "renders form for editing chosen apikey", %{conn: conn, apikey: apikey} do
  #     conn = get(conn, Routes.apikey_path(conn, :edit, apikey))
  #     assert html_response(conn, 200) =~ "Edit Apikey"
  #   end
  # end
  #
  # describe "update apikey" do
  #   setup [:create_apikey]
  #
  #   test "redirects when data is valid", %{conn: conn, apikey: apikey} do
  #     conn = put(conn, Routes.apikey_path(conn, :update, apikey), apikey: @update_attrs)
  #     assert redirected_to(conn) == Routes.apikey_path(conn, :show, apikey)
  #
  #     conn = get(conn, Routes.apikey_path(conn, :show, apikey))
  #     assert html_response(conn, 200) =~ "some updated description"
  #   end
  #
  #   test "renders errors when data is invalid", %{conn: conn, apikey: apikey} do
  #     conn = put(conn, Routes.apikey_path(conn, :update, apikey), apikey: @invalid_attrs)
  #     assert html_response(conn, 200) =~ "Edit Apikey"
  #   end
  # end
  #
  # describe "delete apikey" do
  #   setup [:create_apikey]
  #
  #   test "deletes chosen apikey", %{conn: conn, apikey: apikey} do
  #     conn = delete(conn, Routes.apikey_path(conn, :delete, apikey))
  #     assert redirected_to(conn) == Routes.apikey_path(conn, :index)
  #     assert_error_sent 404, fn ->
  #       get(conn, Routes.apikey_path(conn, :show, apikey))
  #     end
  #   end
  # end
  #
  # defp create_apikey(_) do
  #   apikey = fixture(:apikey)
  #   {:ok, apikey: apikey}
  # end
end
