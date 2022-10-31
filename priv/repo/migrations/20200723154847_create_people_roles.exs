defmodule Auth.Repo.Migrations.CreatePeopleRoles do
  use Ecto.Migration

  def change do
    create table(:people_roles) do
      add :person_id, references(:people, on_delete: :delete_all)
      add :role_id, references(:roles, on_delete: :nothing)
      add :granter_id, references(:people, on_delete: :nothing)
      # elixirforum.com/t/difference-between-utc-datetime-and-naive-datetime/12551
      add :revoked, :utc_datetime
      add :revoker_id, references(:people, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:people_roles, [:person_id, :role_id])
  end
end
