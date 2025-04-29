defmodule ElixirConfEU.LLM.TestFun do
  @moduledoc """
  A set of test function for the LLM.
  """

  use LLMMagic

  @doc """
  Returns the location of the requested element or item.

  ### Parameters
  name: :string - The name of the item to find.
  """
  def item_locator(args, _context) do
    "The #{args["name"]} is in the drawer!"
  end

  @doc """
  Welcomes the user to the conference.
  """
  def welcome(_args, _context) do
    "Welcome to ElixirConfEU 2025!"
  end
end
