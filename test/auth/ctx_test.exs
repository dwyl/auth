defmodule Auth.CtxTest do
  use Auth.DataCase

  alias Auth.Ctx

  describe "apps" do
    alias Auth.Ctx.App

    @valid_attrs %{description: "some description", end: ~N[2010-04-17 14:00:00], name: "some name", url: "some url"}
    @update_attrs %{description: "some updated description", end: ~N[2011-05-18 15:01:01], name: "some updated name", url: "some updated url"}
    @invalid_attrs %{description: nil, end: nil, name: nil, url: nil}

    def app_fixture(attrs \\ %{}) do
      {:ok, app} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Ctx.create_app()

      app
    end

    test "list_apps/0 returns all apps" do
      app = app_fixture()
      assert Ctx.list_apps() == [app]
    end

    test "get_app!/1 returns the app with given id" do
      app = app_fixture()
      assert Ctx.get_app!(app.id) == app
    end

    test "create_app/1 with valid data creates a app" do
      assert {:ok, %App{} = app} = Ctx.create_app(@valid_attrs)
      assert app.description == "some description"
      assert app.end == ~N[2010-04-17 14:00:00]
      assert app.name == "some name"
      assert app.url == "some url"
    end

    test "create_app/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Ctx.create_app(@invalid_attrs)
    end

    test "update_app/2 with valid data updates the app" do
      app = app_fixture()
      assert {:ok, %App{} = app} = Ctx.update_app(app, @update_attrs)
      assert app.description == "some updated description"
      assert app.end == ~N[2011-05-18 15:01:01]
      assert app.name == "some updated name"
      assert app.url == "some updated url"
    end

    test "update_app/2 with invalid data returns error changeset" do
      app = app_fixture()
      assert {:error, %Ecto.Changeset{}} = Ctx.update_app(app, @invalid_attrs)
      assert app == Ctx.get_app!(app.id)
    end

    test "delete_app/1 deletes the app" do
      app = app_fixture()
      assert {:ok, %App{}} = Ctx.delete_app(app)
      assert_raise Ecto.NoResultsError, fn -> Ctx.get_app!(app.id) end
    end

    test "change_app/1 returns a app changeset" do
      app = app_fixture()
      assert %Ecto.Changeset{} = Ctx.change_app(app)
    end
  end
end
