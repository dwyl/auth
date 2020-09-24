defmodule AuthWeb.PeopleView do
  use AuthWeb, :view

  @doc """
  status_string/2 returns a string of status
  """
  def status_string(status_id, statuses) do
    if status_id != nil do
      status = Enum.at(Enum.filter(statuses, fn s -> s.id == status_id end), 0)
      status.text
    else
      "none"
    end
  end

  @doc """
  capitalize/1 captalises the first character of a string.
  checks for nil values to avoid seeing the following error:
  (FunctionClauseError) no function clause matching in String.capitalize/2
  """
  def capitalize(str) do
    if is_nil(str) do
      str
    else
      :string.titlecase(str)
    end
  end
end
