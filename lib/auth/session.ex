defmodule Auth.Session do
  @moduledoc """
  Schema and helper functions for managing Sessions for People/Apps.
  The Epic is https://github.com/dwyl/auth/issues/30 however
  we have chosen to make this *much* simpler for now.
  """
  alias Auth.Repo
  import Ecto.Changeset
  import Ecto.Query, warn: false
  use Ecto.Schema
  import Plug.Conn, only: [assign: 3]

  # This is an MVP of sessions, if you need more, please open an issue!
  schema "sessions" do
    field :app_id, :id
    field :auth_provider, :string
    field :end, :naive_datetime
    field :person_id, :id
    field :user_agent_id, :id

    timestamps()
  end

  @doc """
  `changeset/2` validates the session data before inserting/updating.
  """
  def changeset(session, attrs) do
    cast(session, attrs, [:app_id, :auth_provider, :person_id, :user_agent_id, :end])
    |> validate_required([:app_id, :person_id])
  end

  @doc """
  `insert/1` inserts a session based on the data in the conn.assigns.person
  i.e. we are extending our auth flow to include the concept of a session.
  This will allow us to have multiple active sessions (i.e. devices/browsers) 
  for the same person/app. 
  So you can be logged in to an app from multiple devices.
  """
  def insert(conn, person) do
    %Auth.Session{}
    |> changeset(%{
      app_id: person.app_id,
      person_id: person.id,
      user_agent_id: Auth.UserAgent.get_user_agent_id(conn),
      auth_provider: person.auth_provider
    })
    |> Repo.insert!()
  end

  @doc """
  `start_session/1` starts the session and returns conn with conn.assigns.sid.
  invokes `insert/1` above but returns conn instead of the session record.
  """
  def start_session(conn, person) do
    session = insert(conn, person)
    assign(conn, :sid, session.id)
  end

  @doc """
  `get/1` retrieves the current session from DB 
  based on conn.assigns.person data.
  See tests: test/auth/session_test.exs for sample usage.
  """
  def get(conn) do
    Repo.one(
      from s in __MODULE__,
        # match on UA in case person has multiple devices/sessions
        #  only the sessions that haven't been "ended"
        where:
          s.app_id == ^conn.assigns.person.app_id and
            s.person_id == ^conn.assigns.person.id and
            s.user_agent_id == ^Auth.UserAgent.get_user_agent_id(conn) and
            is_nil(s.end),
        # sort by most recent in case there are older un-ended sessions:
        order_by: [desc: :inserted_at]
    )
  end

  @doc """
  `get_by_id/1` retrieves a session by id.
  """
  def get_by_id(conn) do
    Repo.one(
      from s in __MODULE__,
        where: s.id == ^conn.assigns.sid
    )
  end

  @doc """
  `update_session_end/1` update session to end it.
  """
  def update_session_end(conn) do
    get_by_id(conn)
    |> changeset(%{end: DateTime.utc_now()})
    |> Repo.update!()
  end

  @doc """
  `end_session/1` update session to end it.
  """
  def end_session(conn) do
    update_session_end(conn)
    update_in(conn.assigns, &Map.drop(&1, [:sid]))
  end
end
