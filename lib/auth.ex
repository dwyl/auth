defmodule Auth.Auth do
  alias Auth.User

  def validate_user(uid, %{other: %{password: pw, password_confirmation: nil}}),
    do: validate(uid, pw)

  def validate_user(uid, %{other: %{password: pw, password_confirmation: pw}}),
    do: validate(uid, pw)

  def validate_user(uid, _), do: {:error, "passwords do not match"}

  def validate(uid, password) do
    IO.inspect(:application.get_application(CsGuide.Repo))

    get_by_uid =
      case Application.get_env(:auth, Auth) do
        nil -> :email_hash
        config -> Keyword.get(config, :identity) |> Keyword.get(:uid_field)
      end
      |> (fn
            nil -> Keyword.put([], :email_hash, uid)
            uid_field -> Keyword.put([], uid_field, uid)
          end).()

    with %User{} = user <- User.get_by(get_by_uid),
         true <- Argon2.verify_pass(password, user.password) do
      {:ok, user}
    else
      nil ->
        with _ <- Argon2.no_user_verify() do
          IO.inspect("no user")
          {:error, "invalid credentials"}
        end

      false ->
        IO.inspect("bad pw")
        {:error, "invalid credentials"}
    end
  end

  def login(conn, user) do
    conn
    |> Plug.Conn.put_session(:user_id, user.entry_id)
    |> Plug.Conn.configure_session(renew: true)
  end
end
