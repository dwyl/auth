defmodule Auth.Status do
  use Ecto.Schema
  import Ecto.Changeset
  alias Auth.Repo
  # https://stackoverflow.com/a/47501059/1148249
  alias __MODULE__

  schema "status" do
    field :text, :string
    belongs_to :person, Auth.Person

    timestamps()
  end

  @doc false
  def changeset(status, attrs) do
    status
    |> cast(attrs, [:text])
    |> validate_required([:text])
  end

  def create_status(text, person) do
    %Status{}
    |> changeset(%{text: text})
    |> put_assoc(:person, person)
    |> Repo.insert!()
  end

  def upsert_status(text) do
    case Auth.Repo.get_by(__MODULE__, text: text) do
      # create status
      nil ->
        email = System.get_env("ADMIN_EMAIL")
        person = Auth.Person.get_person_by_email(email)
        create_status(text, person)

      status ->
        status
    end
  end
end
