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
    case Repo.get_by(Auth.UserAgent, user_agent: ua) do
      nil ->
        changeset(%Auth.UserAgent{}, %{user_agent: ua})
        |> Repo.insert!(on_conflict: :nothing)

      user_agent ->
        user_agent
    end
  end
end
