defmodule Auth.StatusTest do
  use Auth.DataCase, async: true
  alias Auth.{Status}

  test "upsert_status/1 inserts or updates a status record" do
    status = Status.upsert_status(%{"text" => "verified"})
    assert status.id == 1

    new_status = Status.upsert_status(%{"text" => "amaze", "id" => "12"})
    assert new_status.id == 12
  end
end
