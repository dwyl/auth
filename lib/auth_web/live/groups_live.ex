defmodule AuthWeb.GroupsLive do
  use AuthWeb, :live_view
  alias Phoenix.Socket.Broadcast
  # run live auth on mount:
  on_mount AuthWeb.LiveAuthController

  @topic "live"

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end


  defp get_person_id(assigns), do: assigns[:person][:id] || 0
  defp get_app_id(assigns), do: assigns[:person][:app_id] || 0

  @impl true
  def handle_event("create", %{"name" => name, "desc" => desc}, socket) do

    create_group(name, desc, socket)
    AuthWeb.Endpoint.broadcast(@topic, "update", :create)
    {:noreply, socket}
  end

  defp create_group(name, desc, socket) do
    person_id = get_person_id(socket.assigns)
    dbg(person_id)
    app_id = get_app_id((socket.assigns))
    dbg(app_id)
    dbg(name)
    dbg(desc)

    # Create the Group
    group = Auth.Group.create(%{
      name: name,
      desc: desc,
      app_id: app_id,
      kind: 1
    })

    role = Auth.Role.get_role!(2)
    {:ok, person_role} =
      Auth.PeopleRoles.insert(app_id, person_id, person_id, role.id)

    group_person = %{
      group_id: group.id,
      people_role_id: person_role.id
    }

    # Insert the GroupPerson Record
    {:ok, _inserted_group_person} = Auth.GroupPeople.create(group_person)


  end

end
