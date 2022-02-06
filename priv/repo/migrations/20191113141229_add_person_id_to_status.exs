defmodule Auth.Repo.Migrations.AddPersonIdToStatus do
  use Ecto.Migration

  def change do
    alter table(:status) do
      add :person_id, references(:people, on_delete: :delete_all)
    end
  end
end
