defmodule AuthWeb.AppController do
  use AuthWeb, :controller
  alias Auth.App

  def index(conn, _params) do
    render(conn, "index.html", apps: Auth.App.list_apps(conn))
  end

  def new(conn, _params) do
    changeset = App.change_app(%App{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"app" => app_params}) do
    # IO.inspect(app_params, label: "app_params:16")
    attrs =
      Map.merge(app_params, %{
        "person_id" => conn.assigns.person.id,
        "status" => 3
      })

    case App.create_app(attrs) do
      {:ok, app} ->
        # IO.inspect(app, label: "app:23")
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
    if conn.assigns.person.id == app.person_id || conn.assigns.person.id == 1 do
      render(conn, "show.html", app: app)
    else
      AuthWeb.AuthController.not_found(conn, "this page does not exist")
    end
  end

  def edit(conn, %{"id" => id}) do
    # IO.inspect(id, label: "edit id:36")
    app = App.get_app!(id)
    #  restrict editing to owner||admin https://github.com/dwyl/auth/issues/99
    if conn.assigns.person.id == app.person_id || conn.assigns.person.id == 1 do
      changeset = App.change_app(app)
      render(conn, "edit.html", app: app, changeset: changeset)
    else
      AuthWeb.AuthController.not_found(conn, "cannot edit app you don't own")
    end
  end

  def update(conn, %{"id" => id, "app" => app_params}) do
    app = App.get_app!(id)
    #  restrict updating to owner||admin https://github.com/dwyl/auth/issues/99
    if conn.assigns.person.id == app.person_id || conn.assigns.person.id == 1 do
      case App.update_app(app, app_params) do
        {:ok, app} ->
          conn
          |> put_flash(:info, "App updated successfully.")
          |> redirect(to: Routes.app_path(conn, :show, app))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html", app: app, changeset: changeset)
      end
    else
      AuthWeb.AuthController.not_found(conn, "cannot update app you don't own")
    end
  end

  def delete(conn, %{"id" => id}) do
    app = App.get_app!(id)

    if conn.assigns.person.id == app.person_id || conn.assigns.person.id == 1 do
      {:ok, _app} = App.delete_app(app)

      conn
      |> put_flash(:info, "App deleted successfully.")
      |> redirect(to: Routes.app_path(conn, :index))
    else
      AuthWeb.AuthController.not_found(conn, "cannot delete app you don't own")
    end
  end

  @doc """
  Reset the API Key in case of suspected compromise.
  """
  def resetapikey(conn, %{"id" => id}) do
    app = App.get_app!(id)

    if conn.assigns.person.id != app.person_id && conn.assigns.person.id != 1 do
      AuthWeb.AuthController.not_found(conn, "cannot reset App API Key you don't own")
    else
      Enum.each(app.apikeys, fn k ->
        if k.status == 3 do
          # retire the apikey
          Auth.Apikey.update_apikey(Map.delete(k, :app), %{status: 6})
        end
      end)

      # Create New API Key:
      Auth.Apikey.create_apikey(app)

      # get the app again and render it:
      conn
      |> put_flash(:info, "Your API Key has been successfully reset")
      |> render("show.html", app: App.get_app!(id))
    end
  end
end
