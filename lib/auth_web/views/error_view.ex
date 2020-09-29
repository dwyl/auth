defmodule AuthWeb.ErrorView do
  use AuthWeb, :view

  # If you want to customize a particular status code
  # for a certain format, you may uncomment below.
  # def render("404.html", _assigns) do
  #   "Hello"
  # end
  def error_message(conn) do
    if Map.has_key?(conn.assigns, :reason)
      and Map.has_key?(conn.assigns.reason, :message) do
      "Sorry, " <> conn.assigns.reason.message
    else
      "Sorry, that page could not be found."
    end
  end

  # def debug(map) do
  #   IO.inspect(map)
  #   ""
  # end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.html" becomes
  # "Not Found".
  def template_not_found(template, _assigns) do
    IO.inspect(template, label: "template")
    Phoenix.Controller.status_message_from_template(template)
  end
end
