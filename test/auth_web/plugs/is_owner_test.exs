defmodule Auth.Plugs.IsOwnerTest do
  use ExUnit.Case, async: true
  # use Plug.Test
  use AuthWeb.ConnCase

  # @opts MyRouter.init([])

  test "returns hello world", %{conn: conn} do
    # Create a test connection
    # conn = conn(:get, "/hello")
    Auth.Plugs.IsOwner.is_owner(conn, %{this: "that"})

    # Invoke the plug
    # conn = MyRouter.call(conn, @opts)

    # Assert the response and status
    # assert conn.state == :sent
    # assert conn.status == 200
    # assert conn.resp_body == "world"
  end
end
