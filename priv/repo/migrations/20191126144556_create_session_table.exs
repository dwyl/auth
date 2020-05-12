defmodule Auth.Repo.Migrations.CreateSessionTable do
  use Ecto.Migration

  def change do
    create table(:sessions) do
      add :auth_token, :binary
      add :refresh_token, :binary
      add :key_id, :integer

      # keep sessions when user is deleted
      add :person_id, references(:people, on_delete: :nothing)
      timestamps()
    end
  end
end
