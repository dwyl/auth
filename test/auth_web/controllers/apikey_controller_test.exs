defmodule AuthWeb.ApikeyControllerTest do
  use AuthWeb.ConnCase

  # alias Auth.Apikey



  # @create_attrs %{client_secret: "some client_secret", description: "some description", key_id: 42, name: "some name", url: "some url"}
  # @update_attrs %{client_secret: "some updated client_secret", description: "some updated description", key_id: 43, name: "some updated name", url: "some updated url"}
  # @invalid_attrs %{client_secret: nil, description: nil, key_id: nil, name: nil, url: nil}
  #
  # def fixture(:apikey) do
  #   {:ok, apikey} = Ctx.create_apikey(@create_attrs)
  #   apikey
  # end
  #
  # describe "index" do
  #   test "lists all apikeys", %{conn: conn} do
  #     conn = get(conn, Routes.apikey_path(conn, :index))
  #     assert html_response(conn, 200) =~ "Listing Apikeys"
  #   end
  # end
  #
  # describe "new apikey" do
  #   test "renders form", %{conn: conn} do
  #     conn = get(conn, Routes.apikey_path(conn, :new))
  #     assert html_response(conn, 200) =~ "New Apikey"
  #   end
  # end
  #
  # describe "create apikey" do
  #   test "redirects to show when data is valid", %{conn: conn} do
  #     conn = post(conn, Routes.apikey_path(conn, :create), apikey: @create_attrs)
  #
  #     assert %{id: id} = redirected_params(conn)
  #     assert redirected_to(conn) == Routes.apikey_path(conn, :show, id)
  #
  #     conn = get(conn, Routes.apikey_path(conn, :show, id))
  #     assert html_response(conn, 200) =~ "Show Apikey"
  #   end
  #
  #   test "renders errors when data is invalid", %{conn: conn} do
  #     conn = post(conn, Routes.apikey_path(conn, :create), apikey: @invalid_attrs)
  #     assert html_response(conn, 200) =~ "New Apikey"
  #   end
  # end
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
