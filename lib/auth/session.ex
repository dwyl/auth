defmodule Auth.Session do
  alias Auth.Repo
  import Ecto.Changeset
  import Ecto.Query, warn: false
  use Ecto.Schema
  # https://stackoverflow.com/a/47501059/1148249
  alias __MODULE__

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
    cast(session, attrs, [:app_id, :person_id, :auth_provider, :user_agent_id, :end_at])
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

  # retrieve the current session from DB based on conn.assigns.person data
  def get(conn) do
    Repo.one(
      from s in Session, 
      where: s.app_id == ^conn.assigns.person.app_id
      and
      s.person_id == ^conn.assigns.person.id
      and # match on UA in case person has multiple devices/sessions
      s.user_agent_id == ^Auth.UserAgent.get_user_agent_id(conn)
      and # only the sessions that haven't been "ended"
      is_nil(s.end_at),
      # sort by most recent in case there are older un-ended sessions:
      order_by: [desc: :inserted_at]
    )
  end

  # update session to end it
  def end_session(conn) do
    get(conn)
    |> changeset(%{end_at: DateTime.utc_now()})
    |> Repo.update()
  end
end
