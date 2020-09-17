defmodule AuthWeb.RoleController do
  use AuthWeb, :controller
  alias Auth.Role
  # import Auth.Plugs.IsOwner

  # plug :is_owner when action in [:index]

  def index(conn, _params) do
    # restrict viewing to only roles owned by the person or default roles:
    apps = Auth.App.list_apps(conn)
    app_ids = Enum.map(apps, fn a -> a.id end)
    roles = Role.list_roles_for_apps(app_ids)
    render(conn, "index.html", roles: roles)
  end

  def new(conn, _params) do
    changeset = Role.change_role(%Role{})
    apps = Auth.App.list_apps(conn)
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
    apps = Auth.App.list_apps(conn)
    # check that the role_params.app_id is owned by the person:
    if person_owns_app?(apps, Map.get(role_params, "app_id")) do
      # never allow the request to define the person_id:
      create_attrs = Map.merge(role_params, %{"person_id" => conn.assigns.person.id})

      case Role.create_role(create_attrs) do
        {:ok, role} ->
          conn
          |> put_flash(:info, "Role created successfully.")
          |> redirect(to: Routes.role_path(conn, :show, role))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "new.html", changeset: changeset, apps: apps)
      end
    else
      # request is attempting to create a role for an app they don't own ...
      changeset = Auth.Role.changeset(%Role{}, role_params)

      conn
      |> put_status(:not_found)
      |> put_flash(:info, "Please select an app you own.")
      |> render("new.html", changeset: changeset, apps: apps)
    end
  end

  def show(conn, %{"id" => id}) do
    role = Role.get_role!(id, conn.assigns.person.id)

    if is_nil(role) do
      AuthWeb.AuthController.not_found(conn, "role not found.")
    else
      render(conn, "show.html", role: role)
    end
  end

  def edit(conn, %{"id" => id}) do
    role = Role.get_role!(id, conn.assigns.person.id)

    if is_nil(role) do
      AuthWeb.AuthController.not_found(conn, "role not found.")
    else
      changeset = Role.change_role(role)
      apps = Auth.App.list_apps(conn)
      render(conn, "edit.html", role: role, changeset: changeset, apps: apps)
    end
  end

  def update(conn, %{"id" => id, "role" => role_params}) do
    role = Role.get_role!(id, conn.assigns.person.id)
    apps = Auth.App.list_apps(conn)
    # cannot update a role that doesn't exist (or they don't own):
    if is_nil(role) do
      AuthWeb.AuthController.not_found(conn, "role not found.")
    else
      # confirm that the person owns the app they are attempting to attach a role to:
      if person_owns_app?(apps, map_get(role_params, "app_id")) do
        case Role.update_role(role, role_params) do
          {:ok, role} ->
            conn
            |> put_flash(:info, "Role updated successfully.")
            |> redirect(to: Routes.role_path(conn, :show, role))

          {:error, %Ecto.Changeset{} = changeset} ->
            apps = Auth.App.list_apps(conn)
            render(conn, "edit.html", role: role, changeset: changeset, apps: apps)
        end
      else
        AuthWeb.AuthController.not_found(conn, "App not found.")
      end
    end
  end

  # https://elixirforum.com/t/map-key-is-a-atom-or-string/13285/2
  # our use-case for this is specific keys in controller params
  # mix gen creates tests with atom keys whereas controller expect string keys!
  defp map_get(map, string_key, default \\ 0) do
    to_string(Map.get(map, string_key) ||
      Map.get(map, String.to_atom(string_key), default))
  end

  defp person_owns_app?(apps, app_id) do
    app_ids = Enum.map(apps, fn a -> to_string(a.id) end)
    Enum.member?(app_ids, app_id)
  end

  def delete(conn, %{"id" => id}) do
    # can only delete a role you own:
    role = Role.get_role!(id, conn.assigns.person.id)

    if is_nil(role) do
      AuthWeb.AuthController.not_found(conn, "role not found.")
    else
      {:ok, _role} = Role.delete_role(role)

      conn
      |> put_flash(:info, "Role deleted successfully.")
      |> redirect(to: Routes.role_path(conn, :index))
    end
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
    # we need to expand grant priviledges see: https://github.com/dwyl/auth/issues/119

    if granter_id == 1 do
      role_id = map_get(params, "role_id")
      person_id = map_get(params, "person_id")
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
      people_roles_id = map_get(params, "people_roles_id")
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
