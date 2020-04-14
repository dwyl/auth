defmodule Auth.StatusTest do
  use Auth.DataCase
  alias Auth.{Status}

  test "upsert_status/1 inserts or updates a status record" do
    status = Status.upsert_status("verified")
    assert status.id == 1

    new_status = Status.upsert_status("amaze")
    IO.inspect(new_status, label: "new_status")
    # assert new_status.id == 2
  end

  # test "create_status/1" do
  #   # tag = tag_fixture()
  #   assert Ctx.list_tags() == [tag]
  # end

end
