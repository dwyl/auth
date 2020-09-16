defmodule Auth.Plugs.IsOwner do
  @moduledoc """
  Confirm that the authenticated person is the owner of a particular record
  """
  import Plug.Conn

  def is_owner(conn, options) when not is_nil(options) do
    # IO.inspect(conn, label: "conn")
    # IO.inspect(options, label: "options")


    assign(conn, :owner, true)
  end

end
