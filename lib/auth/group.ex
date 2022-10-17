defmodule Auth.Group do
  use Ecto.Schema
  import Ecto.Changeset

  schema "groups" do
    field :desc, :binary
    field :kind, :integer
    field :name, :binary

    timestamps()
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:name, :desc, :kind])
    |> validate_required([:name, :desc, :kind])
  end
end
