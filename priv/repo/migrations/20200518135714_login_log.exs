defmodule Auth.Repo.Migrations.LoginLog do
  use Ecto.Migration

  def change do
    create table(:user_agents) do
      add :name, :string

    end

    create table(:login_logs) do
      add :email, :binary
      add :ip_address, :string
      add :person_id, references(:people, on_delete: :nothing)
      add :user_agent_id, references(:user_agents, on_delete: :nothing)

      timestamps()
    end

    create index(:login_logs, [:person_id])
    create index(:login_logs, [:user_agent_id])
    create index(:user_agents, [:name], unique: true)
  end
end
