defmodule Auth.Repo.Migrations.CreateApikeys do
  use Ecto.Migration

  def change do
    create table(:apikeys) do
      add :client_id, :binary
      add :client_secret, :binary
      # add :name, :string
      # add :description, :text
      # add :url, :binary
      add :app_id, references(:apps, on_delete: :nothing)
      add :person_id, references(:people, on_delete: :nothing)
      add :status, references(:status, on_delete: :nothing)

      timestamps()
    end

    create index(:apikeys, [:person_id])
    create index(:apikeys, [:status])
  end
end
