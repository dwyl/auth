defmodule Auth.Repo.Migrations.AddGithubIdToPeople do
  use Ecto.Migration

  # avoid person.id conflicts by keeping person.id as autoincrement in
  # see: https://github.com/dwyl/auth/issues/125
  def change do
    alter table(:people) do
      add :github_id, :integer
    end
  end
end
