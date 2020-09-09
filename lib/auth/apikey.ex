defmodule Auth.Apikey do
  @moduledoc """
  Defines apikeys schema and CRUD functions
  """
  use Ecto.Schema
  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias Auth.Repo
  # https://stackoverflow.com/a/47501059/1148249
  alias __MODULE__

  schema "apikeys" do
    field :client_secret, :binary
    field :client_id, :binary
    field :person_id, :id
    field :status, :id
    belongs_to :app, Auth.App

    timestamps()
  end

  @doc false
  def changeset(apikey, attrs) do
    apikey
    |> cast(attrs, [:client_id, :client_secret, :person_id, :status])
    |> validate_required([:client_secret])
    |> put_assoc(:app, Map.get(attrs, "app"))
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
    from(
      a in __MODULE__,
      where: a.person_id == ^person_id
    )
    |> Repo.all()
    |> Repo.preload(:app)
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
  def get_apikey!(id) do
    __MODULE__
    |> Repo.get!(id)
    |> Repo.preload(:app)
  end

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
