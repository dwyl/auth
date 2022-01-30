defmodule Auth.Status do
  use Ecto.Schema
  import Ecto.Changeset
  alias Auth.Repo
  # https://stackoverflow.com/a/47501059/1148249
  alias __MODULE__
  @admin_email Envar.get("ADMIN_EMAIL")

  schema "status" do
    field :text, :string
    field :desc, :string
    belongs_to :person, Auth.Person

    timestamps()
  end

  @doc false
  def changeset(status, attrs) do
    status
    |> cast(attrs, [:text, :desc, :id])
    |> validate_required([:text])
    |> unique_constraint(:text)
  end

  def create_status(attrs, person) do
    %Status{}
    |> changeset(attrs)
    |> put_assoc(:person, person)
    |> Repo.insert!()
  end

  def upsert_status(attrs) do
    case Auth.Repo.get_by(__MODULE__, text: Map.get(attrs, "text")) do
      # create status
      nil ->
        create_status(attrs, Auth.Person.get_person_by_email(@admin_email))

      status ->
        status
    end
  end

  def list_statuses do
    Repo.all(__MODULE__)
  end
end
