defmodule Auth.GroupPeople do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Auth.{Repo}
  alias __MODULE__

  schema "group_people" do
    field :granter_id, :id
    field :group_id, :id
    field :person_id, :id
    field :role_id, :id
    # revoking only relevant when removing a person from a group
    field :revoker_id, :id
    field :revoked, :utc_datetime

    timestamps()
  end

  def changeset(group_people, attrs) do
    group_people
    |> cast(attrs, [:granter_id, :group_id, :person_id, :role_id, :revoker_id, :revoked])
    |> validate_required([:group_id, :person_id])
  end

  @doc """
  Creates a `group_people` record (i.e. `people` that belong to a `group`).
  """
  def create(attrs) do
    %GroupPeople{}
    |> changeset(attrs)
    |> Repo.insert()
  end


  @doc """
  `get_group_people/1` returns the list of people in a group
  """
  def get_group_people(group_id) do
    Repo.all(
      from(gp in __MODULE__,
        where: gp.group_id == ^group_id,
        join: g in Auth.Group, on: g.id == gp.group_id,
        where: is_nil(gp.revoked), # don't return people that have been revoked
        join: p in Auth.Person, on: p.id == gp.person_id,
        join: r in Auth.Role, on: r.id == gp.role_id,
        select: {g.id, g.name, g.kind, gp.person_id, p.givenName, r.id, r.name, gp.inserted_at}
      )
    )
  end
end
