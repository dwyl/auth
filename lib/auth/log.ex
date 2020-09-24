defmodule Auth.Log do
  @moduledoc """
  Defines login_logs schema and CRUD functions
  """
  alias Auth.Repo
  import Ecto.Changeset
  use Ecto.Schema

  schema "logs" do
    field :app_id, :id
    field :email, Fields.Encrypted
    field :person_id, :id
    field :request_path, Fields.Encrypted
    field :status_id, :id
    field :user_agent_id, :id
    timestamps()
  end

  @doc false
  def changeset(login_log, attrs) do
    login_log
    |> cast(attrs, [:email, :request_path, :person_id, :user_agent_id, :status_id])
  end

  def insert_log(log) do
    %Auth.Log{}
    |> changeset(log)
    |> Repo.insert!()
  end

  def get_by_id(id) do
    Repo.get_by(__MODULE__, id: id)
  end


  # unauthenticated auth request
  def error(conn, params) do
    # IO.inspect(conn, label: "conn:34")
    # IO.inspect(conn.assigns, label: "conn.assigns:34")
    uaid = if Map.has_key?(conn.assigns, :ua) do
      # user_agent string is available
      # IO.inspect(conn.assigns.ua, label: "conn.assigns.ua")
      List.first(String.split(conn.assigns.ua, "|"))
    else
      # no user_agent string in conn
      ua = Auth.UserAgent.upsert(conn)
      ua.id
    end

    insert_log(Map.merge(params, %{
      request_path: conn.request_path,
      user_agent_id: uaid
    }))

    conn
  end
end
