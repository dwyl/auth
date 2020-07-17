defmodule AuthWeb.ApikeyControllerTest do
  use AuthWeb.ConnCase
  use ExUnitProperties

  # alias Auth.Apikey
  # alias AuthWeb.ApikeyController, as: Ctrl
  @email System.get_env("ADMIN_EMAIL")
  @create_attrs %{description: "some description", name: "some name", url: "some url"}
  @update_attrs %{
    client_secret: "updated client sec",
    description: "some updated desc",
    name: "updated name",
    url: "surl"
  }
  @invalid_attrs %{client_secret: nil, description: nil, key_id: nil, name: nil, url: nil}

  describe "Create an AUTH_API_KEY for a given person_id" do
    test "encrypt_encode/1 returns a base58 we can decrypt" do
      person_id = 1
      key = AuthWeb.ApikeyController.encrypt_encode(person_id)

      decrypted =
        key
        |> Base58.decode()
        |> Fields.AES.decrypt()
        |> String.to_integer()

      assert decrypted == person_id
    end

    test "decode_decrypt/1 reverses the operation of encrypt_encode/1" do
      person_id = 4_869_234_521
      key = AuthWeb.ApikeyController.encrypt_encode(person_id)
      id = AuthWeb.ApikeyController.decode_decrypt(key)
      assert person_id == id
    end

    test "create_api_key/1 creates an AUTH_API_KEY" do
      person_id = 123_456_789
      key = AuthWeb.ApikeyController.create_api_key(person_id)
      assert key =~ "/"
    end

    test "decrypt_api_key/1 decrypts an AUTH_API_KEY" do
      person_id = 1234
      key = AuthWeb.ApikeyController.create_api_key(person_id)
      decrypted = AuthWeb.ApikeyController.decrypt_api_key(key)
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
        assert AuthWeb.ApikeyController.decode_decrypt(
                 AuthWeb.ApikeyController.encrypt_encode(int)
               ) == int
      end
    end
  end

  # def fixture(:apikey) do
  #   {:ok, apikey} = Ctx.create_apikey(@create_attrs)
  #   apikey
  # end
  #
  describe "index" do
    test "lists all apikeys", %{conn: conn} do
      person = Auth.Person.get_person_by_email(@email)
      conn = AuthPlug.create_jwt_session(conn, %{email: @email, id: person.id})
      |> get(Routes.apikey_path(conn, :index))

      assert html_response(conn, 200) =~ "Auth API Keys"
    end
  end

  describe "new apikey" do
    test "renders form", %{conn: conn} do
      person = Auth.Person.get_person_by_email(@email)

      conn = AuthPlug.create_jwt_session(conn, %{email: @email, id: person.id})
      |> get(Routes.apikey_path(conn, :new))

      assert html_response(conn, 200) =~ "New Apikey"
    end
  end

  describe "create apikey" do
    test "redirects to show when data is valid", %{conn: conn} do
      person = Auth.Person.get_person_by_email(@email)
      conn = AuthPlug.create_jwt_session(conn, person)
      |> post(Routes.apikey_path(conn, :create), apikey: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.apikey_path(conn, :show, id)

      conn = get(conn, Routes.apikey_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Your AUTH_API_KEY"
    end

    # test "renders errors when data is invalid", %{conn: conn} do
    #   person = Auth.Person.get_person_by_email(@email)
    #   conn = AuthPlug.create_jwt_session(conn, %{email: @email, id: person.id})
    #
    #   conn = post(conn, Routes.apikey_path(conn, :create), apikey: @invalid_attrs)
    #   assert html_response(conn, 200) =~ "New Apikey"
    # end
  end

  describe "edit apikey" do
    test "renders form for editing chosen apikey", %{conn: conn} do
      person = Auth.Person.get_person_by_email(@email)
      conn = AuthPlug.create_jwt_session(conn, person)

      {:ok, key} =
        %{"name" => "test key", "url" => "http://localhost:4000"}
        |> AuthWeb.ApikeyController.make_apikey(person.id)
        |> Auth.Apikey.create_apikey()

      conn = get(conn, Routes.apikey_path(conn, :edit, key.id))
      assert html_response(conn, 200) =~ "Edit Apikey"
    end

    test "attempt to edit a key I don't own > should 404", %{conn: conn} do
      person = Auth.Person.get_person_by_email(@email)

      wrong_person =
        Auth.Person.create_person(%{
          email: "wrong@gmail.com",
          auth_provider: "email"
        })

        conn = AuthPlug.create_jwt_session(conn, wrong_person)

      {:ok, key} =
        %{"name" => "test key", "url" => "http://localhost:4000"}
        |> AuthWeb.ApikeyController.make_apikey(person.id)
        |> Auth.Apikey.create_apikey()

      conn = get(conn, Routes.apikey_path(conn, :edit, key.id))
      assert html_response(conn, 404) =~ "not found"
    end
  end

  describe "update apikey" do
    test "redirects when data is valid", %{conn: conn} do
      person = Auth.Person.get_person_by_email(@email)
      conn = AuthPlug.create_jwt_session(conn, person)

      {:ok, key} =
        %{"name" => "test key", "url" => "http://localhost:4000"}
        |> AuthWeb.ApikeyController.make_apikey(person.id)
        |> Auth.Apikey.create_apikey()

      conn = put(conn, Routes.apikey_path(conn, :update, key.id), apikey: @update_attrs)
      assert redirected_to(conn) == Routes.apikey_path(conn, :show, key)

      conn = get(conn, Routes.apikey_path(conn, :show, key))
      assert html_response(conn, 200) =~ "some updated desc"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      person = Auth.Person.get_person_by_email(@email)
      conn = AuthPlug.create_jwt_session(conn, person)

      {:ok, key} =
        %{"name" => "test key", "url" => "http://localhost:4000"}
        |> AuthWeb.ApikeyController.make_apikey(person.id)
        |> Auth.Apikey.create_apikey()

      conn = put(conn, Routes.apikey_path(conn, :update, key), apikey: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Apikey"
    end

    test "attempt to UPDATE a key I don't own > should 404", %{conn: conn} do
      person = Auth.Person.get_person_by_email(@email)
      # create session with wrong person:
      wrong_person =
        Auth.Person.create_person(%{
          email: "wronger@gmail.com",
          auth_provider: "email"
        })

      conn = AuthPlug.create_jwt_session(conn, wrong_person)

      {:ok, key} =
        %{"name" => "test key", "url" => "http://localhost:4000", "person_id" => person.id}
        |> AuthWeb.ApikeyController.make_apikey(person.id)
        |> Auth.Apikey.create_apikey()

      conn = put(conn, Routes.apikey_path(conn, :update, key.id), apikey: @update_attrs)
      assert html_response(conn, 404) =~ "not found"
    end
  end

  describe "delete apikey" do
    test "deletes chosen apikey", %{conn: conn} do
      person = Auth.Person.get_person_by_email(@email)
      conn = AuthPlug.create_jwt_session(conn, person)

      {:ok, key} =
        %{"name" => "test key", "url" => "http://localhost:4000"}
        |> AuthWeb.ApikeyController.make_apikey(person.id)
        |> Auth.Apikey.create_apikey()

      conn = delete(conn, Routes.apikey_path(conn, :delete, key))
      assert redirected_to(conn) == Routes.apikey_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.apikey_path(conn, :show, key))
      end
    end

    test "cannot delete a key belonging to someone else! 404", %{conn: conn} do
      wrong_person =
        Auth.Person.create_person(%{
          email: "wrongin@gmail.com",
          auth_provider: "email"
        })

      conn = AuthPlug.create_jwt_session(conn, wrong_person)
      person = Auth.Person.get_person_by_email(@email)

      {:ok, key} =
        %{"name" => "test key", "url" => "http://localhost:4000"}
        |> AuthWeb.ApikeyController.make_apikey(person.id)
        |> Auth.Apikey.create_apikey()

      conn = delete(conn, Routes.apikey_path(conn, :delete, key))
      assert html_response(conn, 404) =~ "not found"
    end
  end
end
