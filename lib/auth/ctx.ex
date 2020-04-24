# defmodule Auth.Ctx do
#   @moduledoc """
#   The Ctx context.
#   """
#
#   import Ecto.Query, warn: false
#   alias Auth.Repo
#
#   alias Auth.Ctx.Apikey
#
#   @doc """
#   Returns the list of apikeys.
#
#   ## Examples
#
#       iex> list_apikeys()
#       [%Apikey{}, ...]
#
#   """
#   def list_apikeys do
#     Repo.all(Apikey)
#   end
#
#   @doc """
#   Gets a single apikey.
#
#   Raises `Ecto.NoResultsError` if the Apikey does not exist.
#
#   ## Examples
#
#       iex> get_apikey!(123)
#       %Apikey{}
#
#       iex> get_apikey!(456)
#       ** (Ecto.NoResultsError)
#
#   """
#   def get_apikey!(id), do: Repo.get!(Apikey, id)
#
#   @doc """
#   Creates a apikey.
#
#   ## Examples
#
#       iex> create_apikey(%{field: value})
#       {:ok, %Apikey{}}
#
#       iex> create_apikey(%{field: bad_value})
#       {:error, %Ecto.Changeset{}}
#
#   """
#   def create_apikey(attrs \\ %{}) do
#     %Apikey{}
#     |> Apikey.changeset(attrs)
#     |> Repo.insert()
#   end
#
#   @doc """
#   Updates a apikey.
#
#   ## Examples
#
#       iex> update_apikey(apikey, %{field: new_value})
#       {:ok, %Apikey{}}
#
#       iex> update_apikey(apikey, %{field: bad_value})
#       {:error, %Ecto.Changeset{}}
#
#   """
#   def update_apikey(%Apikey{} = apikey, attrs) do
#     apikey
#     |> Apikey.changeset(attrs)
#     |> Repo.update()
#   end
#
#   @doc """
#   Deletes a apikey.
#
#   ## Examples
#
#       iex> delete_apikey(apikey)
#       {:ok, %Apikey{}}
#
#       iex> delete_apikey(apikey)
#       {:error, %Ecto.Changeset{}}
#
#   """
#   def delete_apikey(%Apikey{} = apikey) do
#     Repo.delete(apikey)
#   end
#
#   @doc """
#   Returns an `%Ecto.Changeset{}` for tracking apikey changes.
#
#   ## Examples
#
#       iex> change_apikey(apikey)
#       %Ecto.Changeset{source: %Apikey{}}
#
#   """
#   def change_apikey(%Apikey{} = apikey) do
#     Apikey.changeset(apikey, %{})
#   end
# end
