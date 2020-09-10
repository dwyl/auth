defmodule AuthWeb.ApikeyControllerTest do
  use AuthWeb.ConnCase

  # @email System.get_env("ADMIN_EMAIL")
  # @create_attrs %{
  #   description: "some description",
  #   name: "some name", url: "localhost",
  #   status: 3,
  #   person_id: 1
  # }
  # @update_attrs %{
  #   client_secret: "updated client sec",
  #   description: "some updated desc",
  #   name: "updated name",
  #   url: "surl",
  #   status: 3
  # }
  # @invalid_attrs %{client_secret: nil, description: nil, key_id: nil, name: nil, url: nil}



  # describe "index" do
  #   test "lists all apikeys", %{conn: conn} do
  #     conn = admin_login(conn)
  #     conn = get(conn, Routes.apikey_path(conn, :index))

  #     assert html_response(conn, 200) =~ "Auth API Keys"
  #   end
  # end

  # describe "new apikey" do
  #   test "renders form", %{conn: conn} do
  #     conn = admin_login(conn)
  #     conn = get(conn, Routes.apikey_path(conn, :new))

  #     assert html_response(conn, 200) =~ "New Apikey"
  #   end
  # end

  # describe "create apikey" do
  #   test "redirects to show when data is valid", %{conn: conn} do
  #     {:ok, app} = Auth.App.create_app(@create_attrs)
  #     IO.inspect(app, label: "app")
  #     conn = admin_login(conn)
  #     params = %{"app" => app}
  #     conn = post(conn, Routes.apikey_path(conn, :create), apikey: params)

  #     assert %{id: id} = redirected_params(conn)
  #     IO.inspect(id, label: "id")
  #     assert redirected_to(conn) == Routes.apikey_path(conn, :show, id)

  #     conn = get(conn, Routes.apikey_path(conn, :show, id))
  #     IO.inspect(conn, label: "conn")
  #     # assert html_response(conn, 200) =~ "Your AUTH_API_KEY"
  #   end
  # end

  # describe "edit apikey" do
  #   test "renders form for editing chosen apikey", %{conn: conn} do
  #     person = Auth.Person.get_person_by_email(@email)
  #     conn = admin_login(conn)

  #     {:ok, key} =
  #       %{"name" => "test key", "url" => "http://localhost:4000"}
  #       |> AuthWeb.ApikeyController.make_apikey(person.id)
  #       |> Auth.Apikey.create_apikey()

  #     conn = get(conn, Routes.apikey_path(conn, :edit, key.id))
  #     assert html_response(conn, 200) =~ "Edit Apikey"
  #   end

  #   test "attempt to edit a key I don't own > should 404", %{conn: conn} do
  #     person = Auth.Person.get_person_by_email(@email)

  #     wrong_person_data = %{
  #       email: "wronger@gmail.com",
  #       auth_provider: "email",
  #       id: 42
  #     }

  #     Auth.Person.create_person(wrong_person_data)
  #     conn = AuthPlug.create_jwt_session(conn, wrong_person_data)

  #     {:ok, key} =
  #       %{"name" => "test key", "url" => "http://localhost:4000"}
  #       |> AuthWeb.ApikeyController.make_apikey(person.id)
  #       |> Auth.Apikey.create_apikey()

  #     conn = get(conn, Routes.apikey_path(conn, :edit, key.id))
  #     assert html_response(conn, 404) =~ "not found"
  #   end
  # end

  # describe "update apikey" do
  #   test "redirects when data is valid", %{conn: conn} do
  #     person = Auth.Person.get_person_by_email(@email)
  #     conn = AuthPlug.create_jwt_session(conn, %{id: person.id})

  #     {:ok, key} =
  #       %{"name" => "test key", "url" => "http://localhost:4000"}
  #       |> AuthWeb.ApikeyController.make_apikey(person.id)
  #       |> Auth.Apikey.create_apikey()

  #     conn = put(conn, Routes.apikey_path(conn, :update, key.id), apikey: @update_attrs)
  #     assert redirected_to(conn) == Routes.apikey_path(conn, :show, key)
  #   end

  #   test "renders errors when data is invalid", %{conn: conn} do
  #     person = Auth.Person.get_person_by_email(@email)
  #     conn = admin_login(conn)

  #     {:ok, key} =
  #       %{"name" => "test key", "url" => "http://localhost:4000"}
  #       |> AuthWeb.ApikeyController.make_apikey(person.id)
  #       |> Auth.Apikey.create_apikey()

  #     conn = put(conn, Routes.apikey_path(conn, :update, key), apikey: @invalid_attrs)
  #     assert html_response(conn, 200) =~ "Edit Apikey"
  #   end

  #   test "attempt to UPDATE a key I don't own > should 404", %{conn: conn} do
  #     person = Auth.Person.get_person_by_email(@email)
  #     # create session with wrong person:
  #     wrong_person_data = %{
  #       email: "wronger@gmail.com",
  #       auth_provider: "email",
  #       id: 42
  #     }

  #     Auth.Person.create_person(wrong_person_data)
  #     conn = AuthPlug.create_jwt_session(conn, wrong_person_data)

  #     {:ok, key} =
  #       %{"name" => "test key", "url" => "http://localhost:4000", "person_id" => person.id}
  #       |> AuthWeb.ApikeyController.make_apikey(person.id)
  #       |> Auth.Apikey.create_apikey()

  #     conn = put(conn, Routes.apikey_path(conn, :update, key.id), apikey: @update_attrs)
  #     assert html_response(conn, 404) =~ "not found"
  #   end
  # end

  # describe "delete apikey" do
  #   test "deletes chosen apikey", %{conn: conn} do
  #     person = Auth.Person.get_person_by_email(@email)
  #     conn = admin_login(conn)

  #     {:ok, key} =
  #       %{"name" => "test key", "url" => "http://localhost:4000"}
  #       |> AuthWeb.ApikeyController.make_apikey(person.id)
  #       |> Auth.Apikey.create_apikey()

  #     conn = delete(conn, Routes.apikey_path(conn, :delete, key))
  #     assert redirected_to(conn) == Routes.apikey_path(conn, :index)

  #     assert_error_sent 404, fn ->
  #       get(conn, Routes.apikey_path(conn, :show, key))
  #     end
  #   end

  #   test "cannot delete a key belonging to someone else! 404", %{conn: conn} do
  #     wrong_person_data = %{
  #       email: "wronger@gmail.com",
  #       auth_provider: "email",
  #       id: 42
  #     }

  #     Auth.Person.create_person(wrong_person_data)
  #     conn = AuthPlug.create_jwt_session(conn, wrong_person_data)
  #     person = Auth.Person.get_person_by_email(@email)

  #     {:ok, key} =
  #       %{"name" => "test key", "url" => "http://localhost:4000"}
  #       |> AuthWeb.ApikeyController.make_apikey(person.id)
  #       |> Auth.Apikey.create_apikey()

  #     conn = delete(conn, Routes.apikey_path(conn, :delete, key))
  #     assert html_response(conn, 404) =~ "not found"
  #   end
  # end
end
