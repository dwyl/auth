defmodule Auth.Repo.Migrations.CreateGroupPeople do
  use Ecto.Migration

  def change do
    create table(:group_people) do
      add :group_id, references(:groups, on_delete: :nothing)
      add :people_role_id, references(:people_roles, on_delete: :nothing)

      timestamps()
    end

    create index(:group_people, [:group_id])
    create index(:group_people, [:people_role_id])
  end
end
