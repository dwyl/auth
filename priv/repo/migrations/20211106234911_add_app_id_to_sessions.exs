defmodule Auth.Repo.Migrations.AddAppIdToSessions do
  use Ecto.Migration

  def change do
    alter table(:sessions) do
      add :app_id, references(:apps, on_delete: :nothing)
      add :auth_provider, :string
      add :end, :naive_datetime
      # avoid tight coupling
      remove :person_id
      add :person_id, references(:people, on_delete: :nothing)
      add :user_agent_id, :integer
      # Don't want to risk leaking auth/refresh tokens in a breach
      # so just not going to store them even encrypted. 
      remove :auth_token
      remove :refresh_token
    end
  end
end
