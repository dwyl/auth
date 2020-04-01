defmodule App.Repo.Migrations.CreatePeople do
  use Ecto.Migration

  def change do
    create table(:people) do
      add :username, :binary
      add :username_hash, :binary
      add :email, :binary
      add :email_hash, :binary
      add :givenName, :binary
      add :familyName, :binary
      add :password_hash, :binary
      add :key_id, :integer
      add :status, references(:status, on_delete: :nothing)
      add :tag, references(:tags, on_delete: :nothing)

      timestamps()
    end

    create index(:people, [:status])
    create index(:people, [:tag])
  end
end
