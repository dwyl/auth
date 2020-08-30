defmodule Auth.Repo.Migrations.CreateApps do
  use Ecto.Migration

  def change do
    create table(:apps) do
      add :name, :binary
      add :description, :binary
      add :url, :binary
      add :end, :naive_datetime
      add :person_id, references(:people, on_delete: :nothing)
      add :status, references(:status, on_delete: :nothing)
      add :apikey_id, references(:apikeys, on_delete: :nothing)

      timestamps()
    end

    create index(:apps, [:person_id])
    create index(:apps, [:status])
    create index(:apps, [:apikey_id])
  end
end
