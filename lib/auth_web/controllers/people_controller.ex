defmodule AuthWeb.PeopleController do
  @moduledoc """
  Defines People controller functions
  """
  use AuthWeb, :controller

  @doc """
  `index/2` lists all the people who have authenticated with the auth app.
  """
  def index(conn, _params) do
    if conn.assigns.person.id == 1 do
      render(conn, :index,
        people: Auth.Person.list_people(),
        roles: Auth.Role.list_roles(),
        statuses: Auth.Status.list_statuses()
      )
      # Note: this can easily be refactored to save on DB queries. #HelpWanted
    else
      AuthWeb.AuthController.unauthorized(conn)
    end
  end
end
