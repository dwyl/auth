defmodule Auth.Repo.Migrations.RenameLoginLogsIssue126 do
  use Ecto.Migration

  # ref: https://github.com/dwyl/auth/issues/126
  def change do
    rename table(:login_logs), to: table(:logs)

    alter table(:logs) do
      remove :ip_address
      add :app_id, references(:apps, on_delete: :nothing)
      add :request_path, :binary
      add :status, references(:status, on_delete: :nothing)
    end

    # :ip_address is encrypted so we can decrypt it later
    # :ip_address_hash is hashed for fast lookups and indexing/constraints
    alter table(:user_agents) do
      add :ip_address, :binary
      add :ip_address_hash, :binary
    end

    # index should be on both :name and :ip_address
    drop_if_exists index(:user_agents, [:name])
    create unique_index(:user_agents, [:name, :ip_address_hash], unique: true)

    # ensure that statuses are unique:
    create unique_index(:status, [:text], unique: true)
  end
end
