defmodule AuthWeb.AppController do
  use AuthWeb, :controller
  alias Auth.App

  def index(conn, _params) do
    apps = App.list_apps()
    render(conn, "index.html", apps: apps)
  end

  def new(conn, _params) do
    changeset = App.change_app(%App{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"app" => app_params}) do
    case App.create_app(app_params) do
      {:ok, app} ->
        conn
        |> put_flash(:info, "App created successfully.")
        |> redirect(to: Routes.app_path(conn, :show, app))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    app = App.get_app!(id)
    #  restrict viewership to owner||admin https://github.com/dwyl/auth/issues/99
    render(conn, "show.html", app: app)
  end

  def edit(conn, %{"id" => id}) do
    app = App.get_app!(id)
    changeset = App.change_app(app)
    render(conn, "edit.html", app: app, changeset: changeset)
  end

  def update(conn, %{"id" => id, "app" => app_params}) do
    app = App.get_app!(id)

    case App.update_app(app, app_params) do
      {:ok, app} ->
        conn
        |> put_flash(:info, "App updated successfully.")
        |> redirect(to: Routes.app_path(conn, :show, app))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", app: app, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    app = App.get_app!(id)
    {:ok, _app} = App.delete_app(app)

    conn
    |> put_flash(:info, "App deleted successfully.")
    |> redirect(to: Routes.app_path(conn, :index))
  end
end
