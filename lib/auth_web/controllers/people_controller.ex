defmodule AuthWeb.PeopleController do
  @moduledoc """
  Defines People controller functions
  """
  use AuthWeb, :controller

  @doc """
  `index/2` lists all the people who have authenticated with the auth app.
  """
  def index(conn, _params) do
    people = Auth.Log.get_list_of_people(conn)
    if length(people) > 0 do
      render(conn, :index, people: people)
    else
      AuthWeb.AuthController.not_found(conn, "No People Using Your App, Yet!")
    end
  end

  @doc """
  `show/2` shows the profile of a person with all relevant info.
  """
  def show(conn, params) do
    # should be visible to superadmin and people with "admin" role
    if conn.assigns.person.id == 1 do
      person = Auth.Person.get_person_by_id(Map.get(params, "person_id"))

      render(conn, :profile,
        person: person,
        roles: Auth.PeopleRoles.get_roles_for_person(person.id),
        statuses: Auth.Status.list_statuses(),
        all_roles: Auth.Role.list_roles(),
        apps: Auth.App.list_apps(conn)
      )

      # Note: this can easily be refactored to save on DB queries. #HelpWanted
    else
      AuthWeb.AuthController.unauthorized(conn)
    end
  end
end
