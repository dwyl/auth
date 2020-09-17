defmodule AuthWeb.RoleView do
  use AuthWeb, :view

  def app_link(app_id) do
    case is_nil(app_id) do
      true -> "all"
      false -> "<a href='/apps/#{app_id}'> #{app_id} </a>"
    end
  end
end
