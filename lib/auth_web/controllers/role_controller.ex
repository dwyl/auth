defmodule AuthWeb.RoleController do
  use AuthWeb, :controller

  alias Auth.Role

  def index(conn, _params) do
    roles = Role.list_roles()
    render(conn, "index.html", roles: roles)
  end

  def new(conn, _params) do
    changeset = Role.change_role(%Role{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"role" => role_params}) do
    case Role.create_role(role_params) do
      {:ok, role} ->
        conn
        |> put_flash(:info, "Role created successfully.")
        |> redirect(to: Routes.role_path(conn, :show, role))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    role = Role.get_role!(id)
    render(conn, "show.html", role: role)
  end

  def edit(conn, %{"id" => id}) do
    role = Role.get_role!(id)
    changeset = Role.change_role(role)
    render(conn, "edit.html", role: role, changeset: changeset)
  end

  def update(conn, %{"id" => id, "role" => role_params}) do
    role = Role.get_role!(id)

    case Role.update_role(role, role_params) do
      {:ok, role} ->
        conn
        |> put_flash(:info, "Role updated successfully.")
        |> redirect(to: Routes.role_path(conn, :show, role))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", role: role, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    role = Role.get_role!(id)
    {:ok, _role} = Role.delete_role(role)

    conn
    |> put_flash(:info, "Role deleted successfully.")
    |> redirect(to: Routes.role_path(conn, :index))
  end
end
