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
    field :status, :id
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


  # unauthenticated auth request
  def error(conn, params) do
    ua = if is_nil(conn.assigns.person) || is_nil(conn.assigns.person.ua) do
      # no user_agent string in conn
      ""
    else
      # user_agent string is available
      conn.assigns.person.ua
    end
  end
end
