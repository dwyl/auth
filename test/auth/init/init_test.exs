defmodule Auth.InitTest do
  use Auth.DataCase, async: true

  describe "Initialize the Auth Database" do
    test "main/0" do
      assert Auth.Init.main() == :ok
    end
  end
end
