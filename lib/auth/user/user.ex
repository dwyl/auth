defmodule Auth.User do
  use Ecto.Schema
  use Alog
  import Ecto.Changeset

  schema "users" do
    field(:email, Fields.EmailEncrypted)
    field(:email_hash, Fields.EmailHash)
    field(:email_plaintext, Fields.EmailPlaintext, virtual: true)
    field(:password, Fields.Password)
    field(:entry_id, :string)
    field(:deleted, :boolean, default: false)
    field(:admin, :boolean, default: false)
    field(:name, :string, virtual: true)
    field(:username, :string, virtual: true)

    timestamps()
  end

  @doc false
  def changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, [:email, :password, :admin])
    |> validate_required([:email])
    |> put_email_hash()
    |> unique_constraint(:email_hash)
  end

  def put_email_hash(user) do
    case get_change(user, :email) do
      nil -> user
      email -> put_change(user, :email_hash, email)
    end
  end

  def registration_changeset(model, params) do
    model
    |> changeset(params)
    |> cast(params, ~w(password))
    |> validate_length(:password, min: 6, max: 100)
    |> put_pass_hash()
  end

  # register with only email address
  def register_changeset(model, params \\ :empty) do
    IO.puts("register_changeset called")
    IO.inspect(params)

    model
    |> IO.inspect()
    |> cast(params, ~w(username name))
    # |> validate_required([:username])
    |> changeset(params)
  end

  defp put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))

      # that underscore matches the error case
      _ ->
        changeset
    end
  end
end
