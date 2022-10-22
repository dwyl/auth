defmodule Auth.GroupPeople do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Auth.{Repo}
  alias __MODULE__

  schema "group_people" do

    field :group_id, :id
    field :people_role_id, :id

    timestamps()
  end

  @doc false
  def changeset(group_people, attrs) do
    group_people
    |> cast(attrs, [:group_id, :people_role_id])
    |> validate_required([])
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
        join: pr in Auth.PeopleRoles, on: pr.id == gp.people_role_id,
        where: is_nil(pr.revoked), # don't return people that have been revoked
        join: p in Auth.Person, on: p.id == pr.person_id,
        join: r in Auth.Role, on: r.id == pr.role_id,
        select: {g.id, g.name, g.kind, pr.person_id, p.givenName, r.id, r.name, gp.inserted_at}
      )
    )
  end
end
