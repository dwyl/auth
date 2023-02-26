defmodule AuthWeb.LiveAuthController do
  @moduledoc """
  `LiveAuthController` defines the functions for auth in `LiveView`
  Keeping the code here to declutter to the main `AuthWeb.AuthController` ...
  This code is explained in:
  github.com/dwyl/phoenix-liveview-chat-example#12-authentication
  Any questions, please ask!
  """
  use AuthWeb, :controller
  import Phoenix.Component, only: [assign_new: 3]

  def on_mount(:default, _params, %{"jwt" => jwt} = _session, socket) do

    socket =
      socket
      |> assign_new(:person, fn ->
        jwt
        |> AuthPlug.Token.verify_jwt!()
        |> AuthPlug.Helpers.strip_struct_metadata()
        |> Useful.atomize_map_keys()
      end)
      |> assign_new(:loggedin, fn -> true end)

    {:cont, socket}
  end

  # def on_mount(:default, _params, _session, socket) do
  #   socket = assign_new(socket, :loggedin, fn -> false end)
  #   {:cont, socket}
  # end

  # def login(conn, _params) do
  #   redirect(conn, external: AuthPlug.get_auth_url(conn, "/"))
  # end

  # def logout(conn, _params) do
  #   conn
  #   |> AuthPlug.logout()
  #   |> put_status(302)
  #   |> redirect(to: "/")
  # end
end
