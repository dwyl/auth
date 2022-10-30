defmodule AuthWeb.GroupsLive do
  use AuthWeb, :live_view
  alias Phoenix.Socket.Broadcast
  @topic "live"

  def mount(_params, _session, socket) do
    {:ok, socket}
  end


  @impl true
  def handle_event("create", %{"name" => name, "desc" => desc}, socket) do
    # person_id = get_person_id(socket.assigns)

    # Item.create_item_with_tags(%{
    #   text: text,
    #   # person_id: person_id,
    #   status: 2,
    #   tags: tags
    # })
    dbg(name)
    dbg(desc)

    AuthWeb.Endpoint.broadcast(@topic, "update", :create)
    {:noreply, socket}
  end

end
