defmodule Auth.Repo.Migrations.AddPictureLocaleToPeople do
  use Ecto.Migration

  def change do
    alter table(:people) do
      add :picture, :binary
      add :locale, :string, default: "en"
      add :auth_provider, :string
    end
  end
end
