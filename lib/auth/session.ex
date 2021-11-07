defmodule Auth.Session do
  alias Auth.Repo
  import Ecto.Changeset
  use Ecto.Schema

  schema "sessions" do
    field :app_id, :id
    field :auth_provider, :string
    field :end_at, :utc_datetime
    # field :key_id, :integer
    field :person_id, :id
    field :user_agent_id, :id
    # belongs_to :person, Auth.Person
    timestamps()
  end

  def changeset(session, attrs) do
    cast(session, attrs, [:app_id, :person_id, :auth_provider, :user_agent_id])
    |> validate_required([:app_id, :person_id])
  end

  def insert(conn) do
    %Auth.Session{}
    |> changeset(%{
      app_id: conn.assigns.person.app_id,
      person_id: conn.assigns.person.id,
      user_agent_id: Auth.UserAgent.get_user_agent_id(conn),
      auth_provider: conn.assigns.person.auth_provider
    })
    |> Repo.insert!()
  end
end
