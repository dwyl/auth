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

  def decode_decrypt(key) do
    key |> Base58.decode |> Fields.AES.decrypt() |> String.to_integer()
  end

  def decrypt_api_key(key) do
    key |> String.split("/") |> List.first() |> decode_decrypt()
  end

  def create(conn, %{"apikey" => apikey_params}) do
    # IO.inspect(apikey_params, label: "apikey_params")
    person_id = conn.assigns.decoded.id

    params = Map.merge(apikey_params, %{
      "client_secret" => encrypt_encode(person_id),
      "client_id" => encrypt_encode(person_id),
      "person_id" => person_id
      })
    case Apikey.create_apikey(params) do
      {:ok, apikey} ->
        conn
        |> put_flash(:info, "Apikey created successfully.")
        |> redirect(to: Routes.apikey_path(conn, :show, apikey))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    apikey = Apikey.get_apikey!(id)
    # combined = apikey.client_id <> "/" <> apikey.client_secret
    render(conn, "show.html", apikey: apikey)
  end

  # def edit(conn, %{"id" => id}) do
  #   apikey = Ctx.get_apikey!(id)
  #   changeset = Ctx.change_apikey(apikey)
  #   render(conn, "edit.html", apikey: apikey, changeset: changeset)
  # end

  # def update(conn, %{"id" => id, "apikey" => apikey_params}) do
  #   apikey = Ctx.get_apikey!(id)
  #
  #   case Ctx.update_apikey(apikey, apikey_params) do
  #     {:ok, apikey} ->
  #       conn
  #       |> put_flash(:info, "Apikey updated successfully.")
  #       |> redirect(to: Routes.apikey_path(conn, :show, apikey))
  #
  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       render(conn, "edit.html", apikey: apikey, changeset: changeset)
  #   end
  # end
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
