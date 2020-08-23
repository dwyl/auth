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

  def role_string(role_id, roles)  do
    if role_id != nil do
      role = Enum.filter(roles, fn r ->
        r.id == role_id
      end) |> Enum.at(0)
      role.name
    else
      "none"
    end
  end
end
