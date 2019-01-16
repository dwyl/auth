defmodule ValidateEmail do
  def validate(email) do
    case Regex.run(~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/, email) do
      nil ->
        {:error, "Invalid email"}
      [email] ->
        {:ok, Regex.run(~r/(\w+)@([\w.]+)/, email)}
    end
  end
end
