defmodule Auth.Ctx.Permission do
  use Ecto.Schema
  import Ecto.Changeset

  schema "permissions" do
    field :desc, :string
    field :name, :string
    field :person_id, :id

    timestamps()
  end

  @doc false
  def changeset(permission, attrs) do
    permission
    |> cast(attrs, [:name, :desc])
    |> validate_required([:name, :desc])
  end
end
