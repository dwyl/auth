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
    cast(login_log, attrs, [:email, :request_path, :person_id, :user_agent_id, :status_id])
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
    {auth_provider, person_id} = if Map.has_key?(conn.assigns, :person) do
      aup = Map.get(conn.assigns.person, :auth_provider)
      {aup, conn.assigns.person.id}
    else
      {nil, nil}
    end

    uaid =
      if Map.has_key?(conn.assigns, :ua) do
        # user_agent string is available
        List.first(String.split(conn.assigns.ua, "|"))
      else
        # no user_agent string in conn
        ua = Auth.UserAgent.upsert(conn)
        ua.id
      end

    insert_log(
      Map.merge(params, %{
        app_id: Map.get(params, :app_id, 1),
        auth_provider: auth_provider,
        person_id: person_id,
        request_path: conn.request_path,
        user_agent_id: uaid
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

  def stringify_conn_params(conn, params) do
    conn.method <> " " <> conn.request_path <>
      " > " <> stringify(params) <>
      " person:" <> get_person_id(conn)
  end

  def get_person_id(conn) do
    if Map.has_key?(conn.assigns, :person) do
      conn.assigns.person.id
    else
      "nil"
    end
  end

  def stringify(map) when is_map(map) do
    map
    |> Map.delete(:__meta__)
    |> Map.delete(:__struct__)
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
end
