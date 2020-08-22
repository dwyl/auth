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
    field :revoked, :naive_datetime
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
  granter_id is the id of the person (admin) granting the role
  grantee_id is the person.id of the person being granted the role
  role_id is the role.id (int, e.g: 4) of th role being granted.
  """
  def revoke(granter_id, grantee_id, role_id) do
    %PeopleRoles{}
    |> cast(%{granter_id: granter_id}, [:granter_id])
    |> put_assoc(:person, Auth.Person.get_person_by_id(grantee_id))
    |> put_assoc(:role, Auth.Role.get_role!(role_id))
    |> Repo.insert()
  end

end
