defmodule Auth.Repo.Migrations.CreateRoles do
  use Ecto.Migration

  def change do
    create table(:roles) do
      add :name, :string
      add :desc, :string
      add :person_id, references(:people, on_delete: :nothing)
      add :app_id, references(:apps, on_delete: :nothing)

      timestamps()
    end

    create index(:roles, [:person_id])
    create index(:roles, [:app_id])
  end
end
