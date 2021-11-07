defmodule Auth.UserAgent do
  @moduledoc """
  Defines UserAgent and all functions for extracting User Agent from conn
  """
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false
  import Plug.Conn
  alias Auth.Repo
  # https://stackoverflow.com/a/47501059/1148249
  # alias __MODULE__

  schema "user_agents" do
    field :name, :string
    field :ip_address, Fields.IpAddressEncrypted
    field :ip_address_hash, Fields.IpAddressHash
  end

  @doc false
  def changeset(attrs) do
    %Auth.UserAgent{}
    |> cast(attrs, [:name, :ip_address, :ip_address_hash])
    |> validate_required([:name, :ip_address])
    |> put_ip_address_hash()
  end

  defp put_ip_address_hash(changeset) do
    put_change(changeset, :ip_address_hash, changeset.changes.ip_address)
  end

  def get_by(name, ip) do
    Repo.one(from(u in __MODULE__, where: u.name == ^name and u.ip_address_hash == ^ip))
  end

  # it makes sense for the Auth.UserAgent.upsert/1 to accept the Plug.Conn
  # because that's where the IP Address and User Agent info are.
  def upsert(conn) do
    ip = get_ip_address(conn)
    name = get_user_agent_string(conn)

    case get_by(name, ip) do
      # not found, insert it:
      nil ->
        Repo.insert!(changeset(%{name: name, ip_address: ip}))

      ua ->
        ua
    end
  end

  def assign_ua(conn) do
    ua = upsert(conn)
    assign(conn, :ua, make_ua_string(ua))
  end

  def get_user_agent_id(conn) do
    if Map.has_key?(conn.assigns, :ua) do
      # user_agent string is available
      List.first(String.split(conn.assigns.ua, "|"))
    else
      # no user_agent string in conn
      ua = Auth.UserAgent.upsert(conn)
      ua.id
    end
  end

  defp get_user_agent_string(conn) do
    user_agent_header =
      Enum.filter(conn.req_headers, fn {k, _} ->
        k == "user-agent"
      end)

    case user_agent_header do
      [{_, ua}] -> ua
      _ -> "undefined_user_agent"
    end
  end

  defp get_ip_address(conn) do
    Enum.join(Tuple.to_list(conn.remote_ip), ".")
  end

  # The ua_string consists of the ua.id and first 6 characters of the sha256
  # hash of the ua.name. This allows us to do a quick integrity check that
  # a request has come from the correct agent.
  #
  def make_ua_string(ua) do
    # Fields.Helpers.hash/2 hashes ua.name with salt so it's difficult to guess
    # see: https://hexdocs.pm/fields/Fields.Helpers.html#hash/2
    hash =
      Fields.Helpers.hash(:sha256, ua.name)
      |> Base.encode64()
      |> String.slice(0..8)

    "#{ua.id}|#{hash}"
  end
end
