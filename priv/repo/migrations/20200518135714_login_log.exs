defmodule Auth.Repo.Migrations.LoginLog do
  use Ecto.Migration

  def change do
    create table(:user_agents) do
      add :user_agent, :binary
    end

    create table(:login_logs) do
      add :email, :binary
      add :ip_address, :binary
      add :person_id, references(:people, on_delete: :nothing)
      add :user_agent_id, references(:user_agents, on_delete: :nothing)

      timestamps()
    end

    create index(:login_logs, [:person_id])
    create index(:login_logs, [:user_agent_id])
  end
end
