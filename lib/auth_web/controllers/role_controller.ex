defmodule AuthWeb.RoleController do
  use AuthWeb, :controller

  alias Auth.Role

  def index(conn, _params) do
    roles = Role.list_roles()
    # IO.inspect(conn.assigns.person, label: "conn.assigns.person")
    render(conn, "index.html", roles: roles)
  end

  defp list_apps(person_id) do
    case person_id == 1 do
      true -> Auth.App.list_apps()
      false -> Auth.App.list_apps(person_id)
    end
  end

  def new(conn, _params) do
    changeset = Role.change_role(%Role{})
    apps = list_apps(conn.assigns.person.id)
    # Roles Ref/Require Apps: https://github.com/dwyl/auth/issues/112
    # Check if the person already has apps:
    if length(apps) > 0 do
      render(conn, "new.html", changeset: changeset, apps: apps)
    else
      # No apps, instruct them to create an App before Role(s):
      conn
      |> put_flash(:info, "Please create an App before attempting to create Roles")
      |> redirect(to: Routes.app_path(conn, :new))
    end
  end

  def create(conn, %{"role" => role_params}) do
    case Role.create_role(role_params) do
      {:ok, role} ->
        conn
        |> put_flash(:info, "Role created successfully.")
        |> redirect(to: Routes.role_path(conn, :show, role))

      {:error, %Ecto.Changeset{} = changeset} ->
        apps = list_apps(conn.assigns.person.id)
        render(conn, "new.html", changeset: changeset, apps: apps)
    end
  end

  def show(conn, %{"id" => id}) do
    role = Role.get_role!(id)
    render(conn, "show.html", role: role)
  end

  def edit(conn, %{"id" => id}) do
    role = Role.get_role!(id)
    changeset = Role.change_role(role)
    apps = list_apps(conn.assigns.person.id)
    render(conn, "edit.html", role: role, changeset: changeset, apps: apps)
  end

  def update(conn, %{"id" => id, "role" => role_params}) do
    role = Role.get_role!(id)

    case Role.update_role(role, role_params) do
      {:ok, role} ->
        conn
        |> put_flash(:info, "Role updated successfully.")
        |> redirect(to: Routes.role_path(conn, :show, role))

      {:error, %Ecto.Changeset{} = changeset} ->
        apps = list_apps(conn.assigns.person.id)
        render(conn, "edit.html", role: role, changeset: changeset, apps: apps)
    end
  end

  def delete(conn, %{"id" => id}) do
    role = Role.get_role!(id)
    {:ok, _role} = Role.delete_role(role)

    conn
    |> put_flash(:info, "Role deleted successfully.")
    |> redirect(to: Routes.role_path(conn, :index))
  end

  @doc """
  grant_role/3 grants a role to the given person
  the conn must have conn.assigns.person to check for admin in order to grant the role.
  grantee_id should be a valid person.id (the person you want to grant the role to) and
  role_id a valid role.id
  """
  def grant(conn, params) do
    # confirm that the granter is either superadmin (conn.assigns.person.id == 1)
    # or has an "admin" role (1 || 2)
    granter_id = conn.assigns.person.id

    if granter_id == 1 do
      role_id = Map.get(params, "role_id")
      person_id = Map.get(params, "person_id")
      Auth.PeopleRoles.insert(granter_id, person_id, role_id)
      redirect(conn, to: Routes.people_path(conn, :show, person_id))
    else
      AuthWeb.AuthController.unauthorized(conn)
    end
  end

  @doc """
  revoke/2 revokes a role
  """
  def revoke(conn, params) do
    # confirm that the granter is either superadmin (conn.assigns.person.id == 1)
    # or has an "admin" role (1 || 2)
    if conn.assigns.person.id == 1 do
      people_roles_id = Map.get(params, "people_roles_id")
      pr = Auth.PeopleRoles.get_by_id(people_roles_id)

      if conn.method == "GET" do
        render(conn, "revoke.html", role: pr, people_roles_id: people_roles_id)
      else
        Auth.PeopleRoles.revoke(conn.assigns.person.id, people_roles_id)
        redirect(conn, to: Routes.people_path(conn, :show, pr.person_id))
      end
    else
      AuthWeb.AuthController.unauthorized(conn)
    end
  end
end
