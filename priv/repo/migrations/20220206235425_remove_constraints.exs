defmodule Auth.Repo.Migrations.RemoveConstraints do
  use Ecto.Migration

  def change do
    # drop(constraint(:status, :status_person_id_fkey))
    drop(constraint(:apps, :apps_person_id_fkey))
    drop(constraint(:apps, :apps_status_fkey))
    drop(constraint(:apikeys, :apikeys_person_id_fkey))
    drop(constraint(:apikeys, :apikeys_status_fkey))
    drop(constraint(:roles, :roles_person_id_fkey))
    # drop(constraint(:people_roles, :people_roles_person_id_fkey))
    # drop(constraint(:people_roles, :people_roles_granter_id_fkey))
  end
end
