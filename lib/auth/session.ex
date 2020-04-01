defmodule Auth.Session do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sessions" do
    field :auth_token, Fields.Encrypted
    field :refresh_token, Fields.Encrypted
    field :key_id, :integer

    belongs_to :person, Auth.Person
    timestamps()
  end

  def changeset(people, attrs) do
    Ecto.build_assoc(people, :sessions)
    |> cast(attrs, [:auth_token, :refresh_token])
    |> validate_required([:auth_token, :refresh_token])
  end

  def basic_changeset(people, _attrs) do
    Ecto.build_assoc(people, :sessions)
  end
end
