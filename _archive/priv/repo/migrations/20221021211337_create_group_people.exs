defmodule Auth.Repo.Migrations.CreateGroupPeople do
  use Ecto.Migration

  def change do
    create table(:group_people) do
      add :group_id, references(:groups, on_delete: :nothing)
      add :granter_id, references(:people, on_delete: :nothing)
      add :person_id, references(:people, on_delete: :nothing)
      add :role_id, references(:roles, on_delete: :nothing)
      # elixirforum.com/t/difference-between-utc-datetime-and-naive-datetime/12551
      add :revoked, :utc_datetime
      add :revoker_id, references(:people, on_delete: :nothing)

      timestamps()
    end

    create index(:group_people, [:granter_id])
    create index(:group_people, [:group_id])
    create index(:group_people, [:person_id])
    create index(:group_people, [:role_id])
    create index(:group_people, [:revoker_id])
  end
end
