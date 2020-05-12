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
    }) |> Auth.Apikey.create_apikey()

    keys = Auth.Apikey.list_apikeys_for_person(person.id)
    assert length(keys) == 3
  end



#
#   alias Auth.Ctx
#
#   describe "apikeys" do
#     alias Auth.Apikey
#
#     @valid_attrs %{client_secret: "some client_secret", description: "some description", key_id: 42, name: "some name", url: "some url"}
#     @update_attrs %{client_secret: "some updated client_secret", description: "some updated description", key_id: 43, name: "some updated name", url: "some updated url"}
#     @invalid_attrs %{client_secret: nil, description: nil, key_id: nil, name: nil, url: nil}
#
#     def apikey_fixture(attrs \\ %{}) do
#       {:ok, apikey} =
#         attrs
#         |> Enum.into(@valid_attrs)
#         |> Ctx.create_apikey()
#
#       apikey
#     end
#

#
#     test "get_apikey!/1 returns the apikey with given id" do
#       apikey = apikey_fixture()
#       assert Ctx.get_apikey!(apikey.id) == apikey
#     end
#
#     test "create_apikey/1 with valid data creates a apikey" do
#       assert {:ok, %Apikey{} = apikey} = Ctx.create_apikey(@valid_attrs)
#       assert apikey.client_secret == "some client_secret"
#       assert apikey.description == "some description"
#       assert apikey.key_id == 42
#       assert apikey.name == "some name"
#       assert apikey.url == "some url"
#     end
#
#     test "create_apikey/1 with invalid data returns error changeset" do
#       assert {:error, %Ecto.Changeset{}} = Ctx.create_apikey(@invalid_attrs)
#     end
#
#     test "update_apikey/2 with valid data updates the apikey" do
#       apikey = apikey_fixture()
#       assert {:ok, %Apikey{} = apikey} = Ctx.update_apikey(apikey, @update_attrs)
#       assert apikey.client_secret == "some updated client_secret"
#       assert apikey.description == "some updated description"
#       assert apikey.key_id == 43
#       assert apikey.name == "some updated name"
#       assert apikey.url == "some updated url"
#     end
#
#     test "update_apikey/2 with invalid data returns error changeset" do
#       apikey = apikey_fixture()
#       assert {:error, %Ecto.Changeset{}} = Ctx.update_apikey(apikey, @invalid_attrs)
#       assert apikey == Ctx.get_apikey!(apikey.id)
#     end
#
#     test "delete_apikey/1 deletes the apikey" do
#       apikey = apikey_fixture()
#       assert {:ok, %Apikey{}} = Ctx.delete_apikey(apikey)
#       assert_raise Ecto.NoResultsError, fn -> Ctx.get_apikey!(apikey.id) end
#     end
#
#     test "change_apikey/1 returns a apikey changeset" do
#       apikey = apikey_fixture()
#       assert %Ecto.Changeset{} = Ctx.change_apikey(apikey)
#     end
#   end
end
