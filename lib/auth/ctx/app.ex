defmodule Auth.Ctx.App do
  use Ecto.Schema
  import Ecto.Changeset

  schema "apps" do
    field :description, :binary
    field :end, :naive_datetime
    field :name, :binary
    field :url, :binary
    field :person_id, :id
    field :status, :id
    field :apikey_id, :id

    timestamps()
  end

  @doc false
  def changeset(app, attrs) do
    app
    |> cast(attrs, [:name, :description, :url, :end])
    |> validate_required([:name, :description, :url, :end])
  end
end
