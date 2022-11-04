defmodule AuthWeb.GroupsLive do
  use AuthWeb, :live_view
  # alias Phoenix.Socket.Broadcast
  # run live auth on mount:
  on_mount AuthWeb.LiveAuthController

  @topic "live"

  @impl true
  def mount(_params, _session, socket) do
    # get person with their groups:
    person_id = get_person_id(socket.assigns)
    groups = Auth.GroupPeople.list_groups_for_person(person_id)
    {:ok, assign(socket, groups: groups)}
    # {:ok, socket}
  end


  defp get_person_id(assigns), do: assigns[:person][:id] || 0
  defp get_app_id(assigns), do: assigns[:person][:app_id] || 0

  @impl true
  def handle_event("create", %{"name" => name, "desc" => desc}, socket) do
    # person_id = get_person_id(socket.assigns)
    create_group(name, desc, socket)
    AuthWeb.Endpoint.broadcast(@topic, "update", :create)
    person_id = get_person_id(socket.assigns)
    groups = Auth.GroupPeople.list_groups_for_person(person_id)
    {:noreply, assign(socket, groups: groups)}
  end

  defp create_group(name, desc, socket) do
    person_id = get_person_id(socket.assigns)
    dbg(person_id)
    app_id = get_app_id((socket.assigns))
    dbg(app_id)
    dbg(name)
    dbg(desc)

    # Create the Group
    {:ok, group} = Auth.Group.create(%{
      name: name,
      desc: desc,
      app_id: app_id,
      kind: 1
    })

    group_person = %{
      grantee_id: person_id,
      group_id: group.id,
      person_id: person_id,
      role_id: 2
    }

    # Insert the GroupPerson Record
    {:ok, inserted_group_person} = Auth.GroupPeople.create(group_person)
    # dbg(inserted_group_person)

  end

end
