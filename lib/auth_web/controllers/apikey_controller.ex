defmodule AuthWeb.ApikeyController do
  use AuthWeb, :controller
  alias Auth.Apikey

  def index(conn, _params) do
    person_id = conn.assigns.decoded.id
    apikeys = Apikey.list_apikeys_for_person(person_id)
    render(conn, "index.html", apikeys: apikeys)
  end

  def new(conn, _params) do
    changeset = Apikey.change_apikey(%Apikey{})
    render(conn, "new.html", changeset: changeset)
  end

  def encrypt_encode(person_id) do
    Fields.AES.encrypt(person_id) |> Base58.encode
  end

  def create_api_key(person_id) do
    encrypt_encode(person_id) <> "/" <> encrypt_encode(person_id)
  end

  @doc"""
  `decode_decrypt/1` accepts a `key` and attempts to Base58.decode
  followed by AES.decrypt it. If decode or decrypt fails, return 0 (zero).
  """
  def decode_decrypt(key) do
    try do
      key |> Base58.decode |> Fields.AES.decrypt() |> String.to_integer()
    rescue
      ArgumentError ->
        # IO.puts("AES.decrypt() unable to decrypt client_id")
        0
    end
  end

  def decrypt_api_key(key) do
    key |> String.split("/") |> List.first() |> decode_decrypt()
  end

  def make_apikey(apikey_params, person_id) do
    Map.merge(apikey_params, %{
      "client_secret" => encrypt_encode(person_id),
      "client_id" => encrypt_encode(person_id),
      "person_id" => person_id
    })
  end

  def create(conn, %{"apikey" => apikey_params}) do
    {:ok, apikey} =
      apikey_params
      |> make_apikey(conn.assigns.decoded.id)
      |> Apikey.create_apikey()

    conn
    |> put_flash(:info, "Apikey created successfully.")
    |> redirect(to: Routes.apikey_path(conn, :show, apikey))
  end

  def show(conn, %{"id" => id}) do
    apikey = Apikey.get_apikey!(id)
    # combined = apikey.client_id <> "/" <> apikey.client_secret
    render(conn, "show.html", apikey: apikey)
  end

  def edit(conn, %{"id" => id}) do
    person_id = conn.assigns.decoded.id
    apikey = Auth.Apikey.get_apikey!(id)
    # IO.inspect(apikey, label: "apikey")
    if apikey.person_id == person_id do
      changeset = Auth.Apikey.change_apikey(apikey)
      render(conn, "edit.html", apikey: apikey, changeset: changeset)
    else
      AuthWeb.AuthController.not_found(conn, "API KEY " <> id <> " not found." )
    end
  end

  @doc """
    `update/2` updates a given API Key. Checks if the person attempting
    to update the key is the "owner" of the key before updating.
  """
  def update(conn, %{"id" => id, "apikey" => apikey_params}) do
    apikey = Apikey.get_apikey!(id)
    

    case Apikey.update_apikey(apikey, apikey_params) do
      {:ok, apikey} ->
        conn
        |> put_flash(:info, "Apikey updated successfully.")
        |> redirect(to: Routes.apikey_path(conn, :show, apikey))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", apikey: apikey, changeset: changeset)
    end
  end
  #
  # def delete(conn, %{"id" => id}) do
  #   apikey = Ctx.get_apikey!(id)
  #   {:ok, _apikey} = Ctx.delete_apikey(apikey)
  #
  #   conn
  #   |> put_flash(:info, "Apikey deleted successfully.")
  #   |> redirect(to: Routes.apikey_path(conn, :index))
  # end
end
