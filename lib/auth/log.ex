defmodule Auth.Log do
  @moduledoc """
  Defines logs schema and CRUD functions
  """
  alias Auth.Repo
  import Ecto.Changeset
  use Ecto.Schema
  require Logger

  schema "logs" do
    field :app_id, :id
    field :auth_provider, :string
    field :email, Fields.Encrypted
    field :msg, :string
    field :person_id, :id
    field :request_path, Fields.Encrypted
    field :status_id, :id
    field :user_agent_id, :id
    timestamps()
  end

  @doc false
  def changeset(login_log, attrs) do
    cast(login_log, attrs, [:app_id, :auth_provider, :email, :msg, :person_id,
      :request_path, :status_id, :user_agent_id])
  end

  def insert_log(log) do
    %Auth.Log{}
    |> changeset(log)
    |> Repo.insert!()
  end

  # def get_by_id(id) do
  #   Repo.get_by(__MODULE__, id: id)
  # end

  def get_all() do
    Repo.all(__MODULE__)
  end

  def insert(conn, params) do
    insert_log(
      Map.merge(params, %{
        app_id: Map.get(params, :app_id, 1),
        auth_provider: get_auth_provider(conn, params),
        person_id: get_person_id(conn, params),
        request_path: conn.request_path,
        user_agent_id: get_user_agent_id(conn),
        email: get_email(conn, params)
      })
    )
    # return conn so we can pipline the log
    conn
  end

  def info(conn, params) do
    Logger.info(stringify_conn_params(conn, params))
    insert(conn, params)
  end

  def error(conn, params) do
    Logger.error(stringify_conn_params(conn, params))
    insert(conn, params)
  end

  defp get_user_agent_id(conn) do
    if Map.has_key?(conn.assigns, :ua) do
      # user_agent string is available
      List.first(String.split(conn.assigns.ua, "|"))
    else
      # no user_agent string in conn
      ua = Auth.UserAgent.upsert(conn)
      ua.id
    end
  end

  defp get_email(conn, params) do
    if Map.has_key?(conn.assigns, :person) do
      Map.get(conn.assigns.person, :email)
    else
      Map.get(params, :email)
    end
  end

  defp stringify_conn_params(conn, params) do
    conn.method <> " " <> conn.request_path
    <> " > " <> stringify(params)
    <> " person:#{get_person_id(conn, params)}"
  end

  defp get_auth_provider(conn, params) do
    if Map.has_key?(conn.assigns, :person) do
      conn.assigns.person.auth_provider
    else
      Map.get(params, :auth_provider)
    end
  end

  defp get_person_id(conn, params) do
    if Map.has_key?(conn.assigns, :person) do
      conn.assigns.person.id
    else
      Map.get(params, :person_id)
    end
  end

  def stringify(map) when is_map(map) do
    map
    |> Map.delete(:__meta__)
    |> Map.delete(:__struct__)
    # avoid leaking personal data in logs
    |> Map.delete(:email)
    |> Map.keys()
    |> Enum.map(fn key ->
      if not is_nil(Map.get(map, key)) do
        "#{key}:#{Map.get(map, key)}"
      end
    end)
    |> Enum.filter(& !is_nil(&1))
    |> Enum.join(", ")
  end

  def stringify(map) when is_nil(map) do
    "nil"
  end

  # get list of people for a given person
  # Auth.Log.get_list_of_people_for_app()
  def get_list_of_people(conn) do
    apps = Auth.App.list_apps(conn) |> Enum.map(fn(a) -> a.id end)
    apps = if length(apps) > 0, do: apps, else: [0]
    query = """
    SELECT l.app_id, l.person_id, p.status,
    st.text as status, p."givenName", p.picture,
    l.inserted_at, p.email, l.auth_provider, r.name
    FROM (
      SELECT DISTINCT ON (person_id) *
      FROM logs
      ORDER BY person_id, inserted_at DESC
    ) l
    JOIN people as p on l.person_id = p.id
    JOIN status as st on p.status = st.id
    JOIN people_roles as pr on p.id = pr.person_id
    JOIN roles as r on pr.role_id = r.id
    WHERE l.app_id in (#{Enum.join(apps, ",")})
    ORDER BY l.inserted_at DESC
    """
    {:ok, result} = Repo.query(query)

    Enum.map(result.rows, fn([aid, pid, sid, s, n, pic, iat, e, aup, role]) ->
      %{
        app_id: aid,
        person_id: pid,
        status: s,
        status_id: sid,
        updated_at: NaiveDateTime.truncate(iat, :second),
        status: s,
        givenName: decrypt(n),
        person_id: pid,
        picture: pic,
        email: decrypt(e),
        auth_provider: aup,
        role: role
      }
    end)
  end

  defp decrypt(ciphertext) do
    ciphertext
    |> Fields.AES.decrypt()
    |> to_string
  end
end
