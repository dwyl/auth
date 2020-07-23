defmodule Auth.Repo.Migrations.CreateRolePermissions do
  use Ecto.Migration

  def change do
    create table(:role_permissions) do
      add :role_id, references(:roles)
      add :permission_id, references(:permissions)
  
      timestamps()
    end
  
    create unique_index(:role_permissionss, [:role_id, :permission_id])
  end
end
