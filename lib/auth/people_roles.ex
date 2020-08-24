defmodule Auth.PeopleRoles do
  @moduledoc """
  Defines people_roles schema and fuction to grant roles to a person.
  """
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Auth.Repo
  # https://stackoverflow.com/a/47501059/1148249
  alias __MODULE__

  schema "people_roles" do
    belongs_to :person, Auth.Person
    belongs_to :role, Auth.Role
    field :granter_id, :integer
    field :revoked, :utc_datetime
    field :revoker_id, :integer

    timestamps()
  end

  @doc """
  list_people_roles/0 returns the list of people_roles with all people data.
  This is useful for displaying the data in a admin overview table.
  """
  def list_people_roles do
    Repo.all(from pr in __MODULE__, preload: [:person, :role])
  end

  @doc """
  get_record/2 returns the record where the person was granted a role.
  """
  def get_record(person_id, role_id) do
    Repo.one(
      from(pr in __MODULE__,
        where: pr.person_id == ^person_id and pr.role_id == ^role_id,
        preload: [:person, :role]
      )
    )
  end

  @doc """
  get_by_id!/1 returns the record with the given people_roles.id.
  """
  def get_by_id(id) do
    Repo.one(
      from(pr in __MODULE__,
        where: pr.id == ^id,
        preload: [:person, :role]
      )
    )
  end

  @doc """
  get_roles_for_person/1 returns the list of roles for a given person.id
  """
  def get_roles_for_person(person_id) do
    IO.inspect(person_id, label: "person_id")
    Repo.all(
      from(pr in __MODULE__,
        where: pr.person_id == ^person_id,
        preload: [:role]
      )
    )
  end

  @doc """
  insert/3 grants a role to the given person
  granter_id is the id of the person (admin) granting the role
  grantee_id is the person.id of the person being granted the role
  role_id is the role.id (int, e.g: 4) of th role being granted.
  """
  def insert(granter_id, grantee_id, role_id) do
    %PeopleRoles{}
    |> cast(%{granter_id: granter_id}, [:granter_id])
    |> put_assoc(:person, Auth.Person.get_person_by_id(grantee_id))
    |> put_assoc(:role, Auth.Role.get_role!(role_id))
    |> Repo.insert()
  end

  @doc """
  revoke/3 grants a role to the given person
  revoker_id is the id of the person (admin) granting the role
  person_id is the person.id of the person being granted the role
  role_id is the role.id (int, e.g: 4) of th role being granted.
  """
  def revoke(revoker_id, people_roles_id) do
    # get the people_role record that needs to be updated (revoked)
    get_by_id(people_roles_id)
    |> cast(
      %{revoker_id: revoker_id, revoked: DateTime.utc_now()},
      [:revoker_id, :revoked]
    )
    |> Repo.update()
  end
end
