defmodule Auth.Repo.Migrations.AddAppIdToPeopleRoles do
  use Ecto.Migration

  def change do
    alter table(:people_roles) do
      add :app_id, references(:apps, on_delete: :nothing)
    end
  end
end
