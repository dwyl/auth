defmodule Auth.AuthController do
  use Auth.Web, :controller
  plug Ueberauth

  alias Ueberauth.Strategy.Helpers

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> IO.inspect
    |> put_flash(:info, "Successfully authenticated.")
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case UserFromAuth.find_or_create(auth) do
      {:ok, user} ->
        conn
        |> IO.inspect
        |> put_flash(:info, "sucessfully authenticated.")
        |> put_session(:current_user, user)
        |> redirect(to: "/")
      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: "/")
    end
  end

  def identity_callback(%{assigns: %{ueberauth_auth: auth}} = conn, params) do
    IO.puts "auth:"
    IO.inspect auth
    case validate_password(auth.credentials) do
      :ok ->
        user = %{id: auth.uid, name: name_from_auth(auth),
          avatar: auth.info.image}
        conn
        |> put_flash(:info, "Successfully authenticated.")
        |> put_session(:current_user, user)
        |> redirect(to: "/")
      { :error, reason } ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: "/")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end

  def request(conn, _params) do
    IO.inspect Helpers.callback_url(conn)
    render(conn, "request.html", callback_url: Helpers.callback_url(conn))
  end

end
