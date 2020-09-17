defmodule Auth.Repo.Migrations.CreatePermissions do
  use Ecto.Migration

  def change do
    create table(:permissions) do
      add :name, :string
      add :desc, :string
      add :person_id, references(:people, on_delete: :nothing)

      timestamps()
    end

    create index(:permissions, [:person_id])
  end
end
