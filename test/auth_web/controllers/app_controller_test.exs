defmodule AuthWeb.AppControllerTest do
  use AuthWeb.ConnCase, async: true
  alias Auth.App

  @create_attrs %{
    desc: "some description",
    end: ~N[2010-04-17 14:00:00],
    name: "some name",
    url: "some url",
    status: 3,
    person_id: 1
  }
  @update_attrs %{
    desc: "some updated description",
    end: ~N[2011-05-18 15:01:01],
    name: "some updated name",
    url: "some updated url"
  }
  @invalid_attrs %{description: nil, end: nil, name: nil, url: nil, person_id: nil}

  def fixture(:app) do
    {:ok, app} = App.create_app(@create_attrs)
    app
  end

  describe "index" do
    setup [:create_app]

    test "lists all apps", %{conn: conn} do
      conn = admin_login(conn)
      conn = get(conn, Routes.app_path(conn, :index))
      assert html_response(conn, 200) =~ "Apps"
    end

    test "non-admin cannot see admin apps", %{conn: conn, app: app} do
      conn = non_admin_login(conn)
      conn = get(conn, Routes.app_path(conn, :index))
      assert html_response(conn, 200) =~ "Apps"
      # the non-admin cannot see the app created in setup:
      assert not String.contains?(conn.resp_body, app.name)
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

  describe "show app" do
    setup [:create_app]

    test "attempt to VIEW app you don't own > 404", %{conn: conn, app: app} do
      conn = non_admin_login(conn)
      conn = get(conn, Routes.app_path(conn, :show, app))
      assert html_response(conn, 404) =~ "page does not exist"
    end
  end

  describe "edit app" do
    setup [:create_app]

    test "renders form for editing chosen app", %{conn: conn, app: app} do
      conn = admin_login(conn)
      conn = get(conn, Routes.app_path(conn, :edit, app))
      assert html_response(conn, 200) =~ "Edit App"
    end

    test "attempt to EDIT app you don't own > 404", %{conn: conn, app: app} do
      conn = non_admin_login(conn)
      conn = get(conn, Routes.app_path(conn, :edit, app))
      assert html_response(conn, 404) =~ "cannot edit"
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

    test "attempt UPDATE app you don't own > 404", %{conn: conn, app: app} do
      conn = non_admin_login(conn)
      conn = put(conn, Routes.app_path(conn, :update, app), app: @update_attrs)
      assert html_response(conn, 404) =~ "cannot update app"
    end
  end

  describe "delete app" do
    setup [:create_app]

    test "deletes chosen app", %{conn: conn, app: app} do
      conn = admin_login(conn)
      conn = delete(conn, Routes.app_path(conn, :delete, app))
      assert redirected_to(conn) == Routes.app_path(conn, :index)

      assert_error_sent 500, fn ->
        get(conn, Routes.app_path(conn, :show, app))
      end
    end

    test "attempt DELETE app you don't own > 404", %{conn: conn, app: app} do
      conn = non_admin_login(conn)
      conn = delete(conn, Routes.app_path(conn, :delete, app))
      assert html_response(conn, 404) =~ "cannot delete app"
    end
  end

  defp create_app(_) do
    app = fixture(:app)
    %{app: app}
  end

  describe "reset apikey" do
    setup [:create_app]

    test "reset apikey for an app", %{conn: conn, app: app} do
      conn = admin_login(conn)
      conn = get(conn, Routes.app_path(conn, :resetapikey, app))
      assert html_response(conn, 200) =~ "successfully reset"
    end

    test "attempt reset apikey you don't own > 404", %{conn: conn, app: app} do
      conn = non_admin_login(conn)
      conn = get(conn, Routes.app_path(conn, :resetapikey, app))
      assert html_response(conn, 404) =~ "cannot reset"
    end

    # ref: https://github.com/dwyl/auth/issues/124
    test "regression test for reset apikeys", %{conn: conn} do
      conn = non_admin_login(conn)

      app_data = %{
        desc: "appdesc",
        name: "appname",
        url: "appurl",
        status: 3,
        person_id: conn.assigns.person.id
      }

      # create app for non_admin:
      {:ok, app} = Auth.App.create_app(app_data)

      #  get apikey before reset:
      apikey1 = Auth.Apikey.get_apikey_by_app_id(app.id)
      get(conn, Routes.app_path(conn, :resetapikey, app))
      apikey2 = Auth.Apikey.get_apikey_by_app_id(app.id)
      assert apikey1.id + 1 == apikey2.id
      state = app.url
      #  The client_id for the original apikey should no longer work:
      sec = AuthWeb.AuthController.get_client_secret(apikey1.client_id, state)
      # so we expect a client_secret of zero:
      assert sec == 0
      # the lookup should work for the new apikey:
      secret = AuthWeb.AuthController.get_client_secret(apikey2.client_id, state)
      assert secret == apikey2.client_secret
    end
  end
end
