defmodule Auth.Status do
  use Ecto.Schema
  import Ecto.Changeset

  schema "status" do
    field :text, :string
    belongs_to :person, App.Ctx.Person

    timestamps()
  end

  @doc false
  def changeset(status, attrs) do
    status
    |> cast(attrs, [:text])
    |> validate_required([:text])
  end
end
