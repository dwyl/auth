defmodule Auth.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field(:email, :string)
    field(:name, :string)
    field(:username, :string)
    field(:password, :string, virtual: true)
    field(:password_hash, :string)
    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, ~w(email))
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/)
    # save unique_constraint for last as DB call
    |> unique_constraint(:email)
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
