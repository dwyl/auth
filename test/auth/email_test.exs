defmodule Auth.EmailTest do
  use ExUnit.Case, async: true

  describe "AuthMvp.Email" do
    test "sendemail/1 an email" do
      params = %{
        "email" => "success@simulator.amazonses.com",
        "name" => "Super Successful",
        "template" => "welcome"
      }

      res = Auth.Email.sendemail(params)
      assert Map.get(params, "email") == Map.get(res, "email")
      assert Map.get(res, "id") > 0
    end

  #   @tag :skip
  #   test "sendemail/1 an email params atom" do
  #     params = %{
  #       email: "success@simulator.amazonses.com",
  #       name: "Super Successful",
  #       template: "welcome"
  #     }

  #     res = Auth.Email.sendemail(params)
  #     assert Map.get(params, :email) == Map.get(res, "email")
  #     assert Map.get(res, "id") > 0
  #   end
  end
end
