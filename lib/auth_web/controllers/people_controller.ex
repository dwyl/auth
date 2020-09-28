defmodule AuthWeb.PeopleController do
  @moduledoc """
  Defines People controller functions
  """
  use AuthWeb, :controller

  @doc """
  `index/2` lists all the people who have authenticated with the auth app.
  """
  def index(conn, _params) do
    people = Auth.Person.get_list_of_people(conn)
    app_ids = Enum.map(Auth.App.list_apps(conn), fn a -> a.id end)

    if length(people) > 0 do
      render(conn, :index, people: people, app_ids: app_ids)
    else
      AuthWeb.AuthController.not_found(conn, "No People Using Your App, Yet!")
    end
  end

  @doc """
  `show/2` shows the profile of a person with all relevant info.
  """
  def show(conn, params) do
    # should be visible to superadmin and people with "admin" role
    apps = Auth.App.list_apps(conn)
    app_ids = Enum.map(Auth.App.list_apps(conn), fn a -> a.id end)

    # if Enum.member?(log_people_ids, person_id) or conn.assigns.person.id == 1 do
    person = Auth.Person.get_person_by_id(Map.get(params, "person_id"))

    render(conn, :profile,
      person: person,
      roles: Auth.PeopleRoles.get_roles_for_person(person.id),
      statuses: Auth.Status.list_statuses(),
      all_roles: Auth.Role.list_roles(),
      apps: apps,
      app_ids: app_ids
    )

      # Note: this can easily be refactored to save on DB queries. #HelpWanted
    # else
    #   AuthWeb.AuthController.unauthorized(conn, "cannot view that person " <> person_id)
    # end
  end
end
