defmodule Auth.InitTest do
  use Auth.DataCase, async: true

  describe "Initialize the Auth Database" do

    test "main/0" do
      Envar.set("MIX_ENV", "test")
      assert Auth.Init.main() == :ok
    end

    test "Delete Everything and init again! (test branches)" do
      Envar.set("MIX_ENV", "test")
      app = Auth.App.get_app!(1)
      Auth.App.delete_app(app)
      # Create then delete admin:
      # person = Auth.Init.create_admin()
      # Auth.Person.delete(person)

      assert Auth.Init.main() == :ok
    end
  end
end
