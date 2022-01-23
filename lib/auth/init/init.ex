defmodule Auth.Init do
  @moduledoc """
  Init as it's name suggests initializes the Auth Application 
  by creating the necessary records in the various tables.

  This is the sequence of steps that are followed to init the App:

  1. Create the "Super Admin" person who owns the Auth App
  based on the `ADMIN_EMAIL` environment/config variable.
  
  > The person.id for the Super Admin will own the remaining records
  so it needs to be created first. 

  2. 

  """

  def hello do
    IO.inspect("hello init")
  end
end