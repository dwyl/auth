defmodule Auth.Repo.Migrations.AddAppIdToSessions do
  use Ecto.Migration

  def change do
    alter table(:sessions) do
      add :app_id, references(:apps, on_delete: :nothing)
      add :auth_provider, :string
      add :person_id, references(:people, on_delete: :nothing)
    end
  end
end
