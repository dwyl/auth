defmodule AuthWeb.GroupsLive do
  use AuthWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
