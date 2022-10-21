defmodule Auth.GroupPeople do
  use Ecto.Schema
  import Ecto.Changeset

  schema "group_people" do

    field :group_id, :id
    field :person_id, :id
    field :people_role_id, :id

    timestamps()
  end

  @doc false
  def changeset(group_people, attrs) do
    group_people
    |> cast(attrs, [])
    |> validate_required([])
  end
end
