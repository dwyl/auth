defmodule Auth.Repo.Migrations.CreateRoles do
  use Ecto.Migration

  def change do
    create table(:roles) do
      add :name, :string
      add :desc, :string
      add :person_id, references(:people, on_delete: :nothing)

      timestamps()
    end

    create index(:roles, [:person_id])
  end
end
