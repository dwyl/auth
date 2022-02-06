defmodule Auth.InitStatuses do

  def statuses do
    [
      %{
        text: "verified", 
        id: "1",
        desc: "People are verified once they confirm their email address"
      },
      %{
        text: "uncategorized", 
        id: "2",
        desc: "All items are uncategorized when they are first created. (Yes, US spelling)"
      },
      %{
        text: "active", 
        id: "3",
        desc: "An App, Item or Person can be active; this is the default state for an App"
      },
      %{
        text: "done", 
        id: "4",
        desc: "Items marked as done are complete"
      },
      %{
        text: "flagged", 
        id: "5",
        desc: "A flagged App, Item or Person requires admin attention"
      },
      %{
        text: "deleted", 
        id: "6",
        desc: "Soft-deleted items that no longer appear in UI but are kept for audit trail purposes"
      },
      %{
        text: "pending", 
        id: "7",
        desc: "When an email or item is ready to be started/sent is still pending"
      },
      %{
        text: "sent", 
        id: "8",
        desc: "An email that has been sent but not yet opened"
      },
      %{
        text: "opened", 
        id: "9",
        desc: "When an email is opened by the recipient"
      },
      %{
        text: "bounce_transient", 
        id: "10",
        desc: "Temporary email bounce e.g. because inbox is full"
      },
      %{
        text: "bounce_permanent", 
        id: "11",
        desc: "Permanent email bounce e.g. when inbox doesn't exist"
      },
      %{
        text: "OK", 
        id: "200",
        desc: "successful HTTP request"
      },
      %{
        text: "Temporary Redirect", 
        id: "307",
        desc: "the request should be repeated with another URI"
      },
      %{
        text: "Permanent Redirect", 
        id: "308",
        desc: "all future requests should be directed to the given URI"
      },
      %{
        text: "Bad Request", 
        id: "400",
        desc: "server cannot or will not process the request due to an apparent client error"
      },
      %{
        text: "Unauthorized", 
        id: "401",
        desc: "when authentication is required and has failed"
      },
      %{
        text: "Forbidden", 
        id: "403",
        desc: "request forbidden"
      },
      %{
        text: "Not Found", 
        id: "404",
        desc: "requested resource could not be found"
      },
      %{
        text: "Too Many Requests", 
        id: "429",
        desc: "has sent too many requests in a given amount of time"
      },
      %{
        text: "Internal Server Error", 
        id: "500",
        desc: "an unexpected condition was encountered"
      }
    ]
  end

  def insert_statuses do
    Enum.each(statuses(), fn status ->
      Auth.Status.upsert_status(status)
    end)
  end

  # def delete_statuses do
  #   Enum.each(statuses(), fn status ->
  #     Auth.Status.delete_status(status)
  #   end)
  # end
end