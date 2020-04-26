defmodule Auth.Apikey do
  use Ecto.Schema
  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias Auth.Repo
  # https://stackoverflow.com/a/47501059/1148249
  alias __MODULE__

  schema "apikeys" do
    field :client_secret, :binary
    field :client_id, :binary
    field :description, :string
    field :name, :string
    field :url, :binary
    field :person_id, :id
    field :status, :id

    timestamps()
  end

  @doc false
  def changeset(apikey, attrs) do
    apikey
    |> cast(attrs, [:client_id, :client_secret, :name, :description, :url, :person_id])
    |> validate_required([:client_secret])
  end

  def change_apikey(%Apikey{} = apikey) do
    Apikey.changeset(apikey, %{})
  end

  def create_apikey(attrs \\ %{}) do
    %Apikey{}
    |> Apikey.changeset(attrs)
    |> Repo.insert()
  end

  def list_apikeys_for_person(person_id) do
    # IO.inspect(person_id, label: "person_id")
    query = from(
      a in __MODULE__,
      where: a.person_id == ^person_id,
      select: a
    )
    Repo.all(query)
  end

  @doc """
  Gets a single apikey.

  Raises `Ecto.NoResultsError` if the Apikey does not exist.

  ## Examples

      iex> get_apikey!(123)
      %Apikey{}

      iex> get_apikey!(456)
      ** (Ecto.NoResultsError)

  """
  def get_apikey!(id), do: Repo.get!(__MODULE__, id)

end
