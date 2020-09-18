defmodule Auth.Repo.Migrations.AddAppIdToPeopleRoles do
  use Ecto.Migration

  def change do
    alter table(:people_roles) do
      add :app_id, references(:apps, on_delete: :nothing)
    end

    #  drop old unique index and re-create to include :app_id
    drop_if_exists unique_index(:people_roles, [:person_id, :role_id])
    create unique_index(:people_roles, [:person_id, :role_id, :app_id])
  end
end
