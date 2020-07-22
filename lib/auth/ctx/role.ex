defmodule Auth.Ctx.Role do
  use Ecto.Schema
  import Ecto.Changeset

  schema "roles" do
    field :desc, :string
    field :name, :string
    field :person_id, :id

    timestamps()
  end

  @doc false
  def changeset(role, attrs) do
    role
    |> cast(attrs, [:name, :desc])
    |> validate_required([:name, :desc])
  end
end
