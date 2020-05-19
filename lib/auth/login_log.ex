defmodule Auth.LoginLog do
  use Ecto.Schema
  import Ecto.Changeset
  alias Auth.Repo

  schema "login_logs" do
    field :email, :string
    field :ip_address, :string
    field :auth_provider, :string
    belongs_to :person, Auth.Person
    belongs_to :user_agent, Auth.UserAgent

    timestamps()
  end

  @doc false
  def changeset(login_log, attrs) do
    login_log
    |> cast(attrs, [:email, :ip_address, :auth_provider])
    |> validate_required([:email])
  end

  def create_login_log(log, person, user_agent) do
    log =
      %Auth.LoginLog{}
      |> changeset(log)
      |> put_assoc(:person, person)
      |> put_assoc(:user_agent, user_agent)

    Repo.insert!(log)
  end
end
