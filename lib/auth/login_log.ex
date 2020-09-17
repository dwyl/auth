defmodule Auth.LoginLog do
  @moduledoc """
  Defines login_logs schema and CRUD functions
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Auth.Repo

  schema "login_logs" do
    field :email, Fields.Encrypted
    field :ip_address, Fields.IpAddressEncrypted
    belongs_to :person, Auth.Person
    field :user_agent_id, :integer
    timestamps()
  end

  @doc false
  def changeset(login_log, attrs) do
    login_log
    |> cast(attrs, [:email, :ip_address, :person_id, :user_agent_id])
  end

  def create_login_log(log) do
    %Auth.LoginLog{}
    |> changeset(log)
    |> Repo.insert!()
  end
end
