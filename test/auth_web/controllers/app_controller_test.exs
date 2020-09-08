defmodule AuthWeb.AppControllerTest do
  use AuthWeb.ConnCase

  alias Auth.App

  @create_attrs %{description: "some description", end: ~N[2010-04-17 14:00:00], name: "some name", url: "some url"}
  @update_attrs %{description: "some updated description", end: ~N[2011-05-18 15:01:01], name: "some updated name", url: "some updated url"}
  @invalid_attrs %{description: nil, end: nil, name: nil, url: nil, person_id: nil}

  def fixture(:app) do
    {:ok, app} = App.create_app(@create_attrs)
    app
  end

  describe "index" do
    test "lists all apps", %{conn: conn} do
      conn = admin_login(conn)
      conn = get(conn, Routes.app_path(conn, :index))
      assert html_response(conn, 200) =~ "Apps"
    end
  end

  describe "new app" do
    test "renders form", %{conn: conn} do
      conn = admin_login(conn)
      conn = get(conn, Routes.app_path(conn, :new))
      assert html_response(conn, 200) =~ "New App"
    end
  end

  describe "create app" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = admin_login(conn)
      conn = post(conn, Routes.app_path(conn, :create), app: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.app_path(conn, :show, id)

      conn = get(conn, Routes.app_path(conn, :show, id))
      assert html_response(conn, 200) =~ "App"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = admin_login(conn)
      conn = post(conn, Routes.app_path(conn, :create), app: @invalid_attrs)
      assert html_response(conn, 200) =~ "New App"
    end
  end

  describe "edit app" do
    setup [:create_app]

    test "renders form for editing chosen app", %{conn: conn, app: app} do
      conn = admin_login(conn)
      conn = get(conn, Routes.app_path(conn, :edit, app))
      assert html_response(conn, 200) =~ "Edit App"
    end
  end

  describe "update app" do
    setup [:create_app]

    test "redirects when data is valid", %{conn: conn, app: app} do
      conn = admin_login(conn)
      conn = put(conn, Routes.app_path(conn, :update, app), app: @update_attrs)
      assert redirected_to(conn) == Routes.app_path(conn, :show, app)

      conn = get(conn, Routes.app_path(conn, :show, app))
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, app: app} do
      conn = admin_login(conn)
      conn = put(conn, Routes.app_path(conn, :update, app), app: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit App"
    end
  end

  describe "delete app" do
    setup [:create_app]

    test "deletes chosen app", %{conn: conn, app: app} do
      conn = admin_login(conn)
      conn = delete(conn, Routes.app_path(conn, :delete, app))
      assert redirected_to(conn) == Routes.app_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.app_path(conn, :show, app))
      end
    end
  end

  defp create_app(_) do
    app = fixture(:app)
    %{app: app}
  end
end
