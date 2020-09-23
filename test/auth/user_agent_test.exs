defmodule Auth.UserAgentTest do
  use Auth.DataCase
  alias Auth.UserAgent

  test "Auth.UserAgent.upsert/1 inserts or gets a user_agent record" do

    conn = %{
      remote_ip: {127, 0, 0, 1},
      req_headers: [
        {"accept",
         "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"},
        {"user-agent",
         "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Safari/605.1.15"}
      ]
    }

    # confirm that useragent is only inserted once:
    ua1 = UserAgent.upsert(conn)
    ua2 = UserAgent.upsert(conn)

    assert ua1.id == ua2.id
  end

  test "Auth.UserAgent.assign_ua/1 assigns the ua string to conn.assigns" do

    conn = %Plug.Conn{
      remote_ip: {88, 123, 42, 86},
      req_headers: [
        {"accept",
         "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"},
        {"user-agent",
         "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/605.1.15 (KHTML, like Gecko)"}
      ]
    }
    ua = UserAgent.upsert(conn)
    ua_string = UserAgent.make_ua_string(ua)
    conn1 = UserAgent.assign_ua(conn)
    # IO.inspect(conn1, label: "conn1")
    assert conn1.assigns.ua == ua_string
  end
end
