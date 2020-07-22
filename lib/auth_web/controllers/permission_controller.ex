defmodule AuthWeb.PermissionController do
  use AuthWeb, :controller

  alias Auth.Ctx
  alias Auth.Ctx.Permission

  def index(conn, _params) do
    permissions = Ctx.list_permissions()
    render(conn, "index.html", permissions: permissions)
  end

  def new(conn, _params) do
    changeset = Ctx.change_permission(%Permission{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"permission" => permission_params}) do
    case Ctx.create_permission(permission_params) do
      {:ok, permission} ->
        conn
        |> put_flash(:info, "Permission created successfully.")
        |> redirect(to: Routes.permission_path(conn, :show, permission))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    permission = Ctx.get_permission!(id)
    render(conn, "show.html", permission: permission)
  end

  def edit(conn, %{"id" => id}) do
    permission = Ctx.get_permission!(id)
    changeset = Ctx.change_permission(permission)
    render(conn, "edit.html", permission: permission, changeset: changeset)
  end

  def update(conn, %{"id" => id, "permission" => permission_params}) do
    permission = Ctx.get_permission!(id)

    case Ctx.update_permission(permission, permission_params) do
      {:ok, permission} ->
        conn
        |> put_flash(:info, "Permission updated successfully.")
        |> redirect(to: Routes.permission_path(conn, :show, permission))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", permission: permission, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    permission = Ctx.get_permission!(id)
    {:ok, _permission} = Ctx.delete_permission(permission)

    conn
    |> put_flash(:info, "Permission deleted successfully.")
    |> redirect(to: Routes.permission_path(conn, :index))
  end
end
