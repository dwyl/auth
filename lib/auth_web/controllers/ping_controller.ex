defmodule AuthWeb.PingController do
  use AuthWeb, :controller

  # see: github.com/dwyl/ping
  def ping(conn, params) do
    Ping.render_pixel(conn, params)
  end
end