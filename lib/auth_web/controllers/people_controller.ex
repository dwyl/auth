defmodule AuthWeb.PeopleController do
  @moduledoc """
  Defines People controller functions
  """
  use AuthWeb, :controller

  @doc """
  `index/2` lists all the people who have authenticated with the auth app.
  """
  def index(conn, _params) do
    people = Auth.Person.get_list_of_people()
    app_ids = Enum.map(Auth.App.list_apps(conn), fn a -> a.id end)
    render(conn, :index, people: people, app_ids: app_ids)
  end

  @spec show(Plug.Conn.t(), map) :: Plug.Conn.t()
  @doc """
  `show/2` shows the profile of a person with all relevant info.
  """
  def show(conn, params) do
    apps = Auth.App.list_apps(conn)
    app_ids = Enum.map(apps, fn a -> a.id end)
    person = Auth.Person.get_person_by_id(Map.get(params, "person_id"))

    render(conn, :profile,
      person: person,
      roles: Auth.PeopleRoles.get_roles_for_person(person.id),
      statuses: Auth.Status.list_statuses(),
      all_roles: Auth.Role.list_roles(),
      apps: apps,
      app_ids: app_ids
    )
  end
end
