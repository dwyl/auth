defmodule Auth.AppTest do
  use Auth.DataCase

  describe "apps" do
    alias Auth.App

    @valid_attrs %{
      desc: "some description",
      end: ~N[2010-04-17 14:00:00],
      name: "some name",
      url: "some url",
      status: 3
    }
    @update_attrs %{
      desc: "some updated description",
      end: ~N[2011-05-18 15:01:01],
      name: "some updated name",
      url: "some updated url",
      status: 3
    }
    @invalid_attrs %{description: nil, end: nil, name: nil, url: nil}

    def app_fixture(attrs \\ %{}) do
      {:ok, app} =
        attrs
        |> Enum.into(@valid_attrs)
        |> App.create_app()

      app
    end

    test "list_apps/0 returns all apps" do
      app = app_fixture()
      a = List.first(Enum.filter(App.list_apps(), fn a -> a.id == app.id end))
      assert a.id == app.id
    end

    test "get_app!/1 returns the app with given id" do
      app = app_fixture(%{person_id: 1})
      a = App.get_app!(app.id)
      assert a.id == app.id
    end

    test "create_app/1 with valid data creates a app" do
      assert {:ok, %App{} = app} = App.create_app(@valid_attrs)
      assert app.desc == "some description"
      assert app.end == ~N[2010-04-17 14:00:00]
      assert app.name == "some name"
      assert app.url == "some url"
    end

    test "create_app/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = App.create_app(@invalid_attrs)
    end

    test "update_app/2 with valid data updates the app" do
      app = app_fixture()
      assert {:ok, %App{} = app} = App.update_app(app, @update_attrs)
      assert app.desc == "some updated description"
      assert app.end == ~N[2011-05-18 15:01:01]
      assert app.name == "some updated name"
      assert app.url == "some updated url"
    end

    test "update_app/2 with invalid data returns error changeset" do
      app = app_fixture()
      assert {:error, %Ecto.Changeset{}} = App.update_app(app, @invalid_attrs)
      assert app == App.get_app!(app.id)
    end

    test "delete_app/1 deletes the app" do
      app = app_fixture()
      assert {:ok, %App{}} = App.delete_app(app)
      app = App.get_app!(app.id)
      assert is_nil(app)
    end

    test "change_app/1 returns a app changeset" do
      app = app_fixture()
      assert %Ecto.Changeset{} = App.change_app(app)
    end
  end
end
