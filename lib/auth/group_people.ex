defmodule Auth.GroupPeople do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Auth.{Group, Person, Repo, Role}
  alias __MODULE__

  schema "group_people" do
    field :granter_id, :integer
    belongs_to :group, Group
    belongs_to :person, Person
    belongs_to :role, Role
    # revoking only relevant when removing a person from a group
    field :revoker_id, :id
    field :revoked, :utc_datetime

    timestamps()
  end

  def changeset(attrs) do
    %GroupPeople{}
    |> cast(attrs, [:granter_id, :group_id, :person_id, :role_id, :revoker_id, :revoked])
    |> validate_required([:group_id, :person_id])
    # |> foreign_key_constraint(:person_id)

  end

  @doc """
  Creates a `group_people` record (i.e. `people` that belong to a `group`).
  """
  def create(attrs) do

    changeset(attrs)
    |> put_assoc(:group, Group.get_group_by_id(attrs.group_id))
    |> put_assoc(:person, Person.get_person_by_id(attrs.person_id))
    |> put_assoc(:role, Role.get_role!(attrs.role_id))
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
        select: {g.id, g.name, g.kind, gp.person_id, p.givenName, p.picture, r.id, r.name, gp.inserted_at}
      )
    )
  end

  @doc """
  `list_groups_for_person` List the groups the person is a member of
  """
  def list_groups_for_person(person_id) do
    Repo.all(
      from(gp in Auth.GroupPeople,
        where: gp.person_id == ^person_id,
        join: g in Auth.Group, on: g.id == gp.group_id,
        where: is_nil(gp.revoked), # don't return people that have been revoked
        # join: p in Auth.Person, on: p.id == gp.person_id,
        # join: r in Auth.Role, on: r.id == gp.role_id,
        select: %{
          id: g.id,
          name: g.name,
          desc: g.desc,
          kind: g.kind,
          inserted_at: g.inserted_at
          # role_name: r.name
        }
      )
    )
  end
end