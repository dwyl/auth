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
    query =
      from(
        a in __MODULE__,
        where: a.person_id == ^person_id
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

  @doc """
  Updates a apikey.

  ## Examples

      iex> update_apikey(apikey, %{field: new_value})
      {:ok, %Apikey{}}

      iex> update_apikey(apikey, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_apikey(%Apikey{} = apikey, attrs) do
    apikey
    |> changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a apikey.

  ## Examples

      iex> delete_apikey(apikey)
      {:ok, %Apikey{}}

      iex> delete_apikey(apikey)
      {:error, %Ecto.Changeset{}}

  """
  def delete_apikey(%Apikey{} = apikey) do
    Repo.delete(apikey)
  end
end
