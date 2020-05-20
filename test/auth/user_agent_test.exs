defmodule Auth.UserAGentTest do
  use Auth.DataCase
  alias Auth.UserAgent

  test "get_or_insert_user_agent/1 inserts or gets a user agent record" do
    ua1 = UserAgent.get_or_insert_user_agent("useragent1")
    ua2 = UserAgent.get_or_insert_user_agent("useragent1")

    assert ua1.id == ua2.id
  end
end
