defmodule AuthWeb.ApiController do
  @moduledoc """
  ApiController includes all functions for our RESTfull API in one place.
  """
  use AuthWeb, :controller

  @doc """
  `approles/2` Returns the (JSON) List of Roles for a given App based on apikey.client_id
  Sample output: https://github.com/dwyl/auth/issues/120#issuecomment-695354317
  """
  def approles(conn, %{"client_id" => client_id}) do
    app_id = Auth.Apikey.decode_decrypt(client_id)

    # return empty JSON list with 401 status if client_id is invalid
    if app_id == 0 or is_nil(app_id) do
      AuthWeb.AuthController.unauthorized(conn)
    else
      roles = Auth.Role.list_roles_for_app(app_id)
      roles = Enum.map(roles, fn role -> Auth.Role.strip_meta(role) end)
      json(conn, roles)
    end
  end

  @doc """
  `personroles/2` Returns the (JSON) List of Roles for a given person (and App)
  e.g: /personroles/:person_id/:client_id
  Sample output: https://github.com/dwyl/auth/issues/121#issuecomment-695360870
  """
  def personroles(conn, %{"person_id" => person_id, "client_id" => client_id}) do
    app_id = Auth.Apikey.decode_decrypt(client_id)

    # return empty JSON list with 401 status if client_id is invalid
    if app_id == 0 or is_nil(app_id) do
      AuthWeb.AuthController.unauthorized(conn)
    else
      roles = Auth.PeopleRoles.get_roles_for_person_for_app(app_id, person_id)

      roles =
        Enum.map(roles, fn role ->
          # it's easier if we just control exactly what data we return:
          %{
            name: role.role.name,
            desc: role.role.desc,
            inserted_at: role.inserted_at,
            role_id: role.role_id
          }
        end)

      json(conn, roles)
    end
  end
end
