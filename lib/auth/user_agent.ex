defmodule Auth.UserAgent do
  use Ecto.Schema
  import Ecto.Changeset
  alias Auth.Repo

  schema "user_agents" do
    field :user_agent, :string
    has_many :login_logs, Auth.LoginLog
  end

  @doc false
  def changeset(user_agent, attrs) do
    user_agent
    |> cast(attrs, [:user_agent])
    |> validate_required([:user_agent])
    |> unique_constraint(:user_agent)
  end

  def get_or_insert_user_agent(ua) do
    Repo.insert!(
      %Auth.UserAgent{user_agent: ua},
      on_conflict: :nothing
    )
  end
end
