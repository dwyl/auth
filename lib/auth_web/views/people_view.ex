defmodule AuthWeb.PeopleView do
  use AuthWeb, :view

  def status_string(status_id, statuses)  do
    if status_id != nil do
      status = Enum.filter(statuses, fn s ->
        s.id == status_id
      end) |> Enum.at(0)
      status.text
    else
      "none"
    end
  end

  def role_string(person_roles)  do
    Enum.map_join(person_roles, " ", fn r ->
      r.name
    end)
  end
end
