defmodule Auth.PeopleRoles do
  use Ecto.Schema
  import Ecto.Changeset
  alias Auth.Repo
  alias __MODULE__

  schema "people_roles" do
    belongs_to :person, Auth.Person
    belongs_to :role, Auth.Role
    field :granter_id, :integer

    timestamps()
  end


  @doc """
  grant_role/3 grants a role to the given person
  the conn must have conn.assigns.person to check for admin in order to grant the role.
  """
  def grant_role(conn, grantee_id, role_id) do
    granter = conn.assigns.person
    # IO.inspect(granter, label: "granter")
    # confirm that the granter is either superadmin (conn.assigns.person.id == 1) 
    # or has an "admin" role (1 || 2)
    if granter.id == 1 do
      %PeopleRoles{}
      |> cast(%{granter_id: granter.id}, [:granter_id])
      |> put_assoc(:person, Auth.Person.get_person_by_id(grantee_id))
      |> put_assoc(:role, Auth.Role.get_role!(role_id))
      |> Repo.insert()

      conn
    else
      AuthWeb.AuthController.unauthorized(conn)
    end

  end

end