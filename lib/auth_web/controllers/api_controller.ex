defmodule AuthWeb.ApiController do
  @moduledoc """
  ApiController includes all functions for our RESTfull API in one place.
  """
  use AuthWeb, :controller

  @doc """
  `approles/2` Return the (JSON) List of Roles for a given App based on apikey.client_id
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
end
