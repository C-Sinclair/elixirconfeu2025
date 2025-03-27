defmodule ElixirConfEU.LLM.TestFun do
  @moduledoc """
  A set of test function for the LLM.
  """

  use ElixirConfEU.LLM.Macros

  @doc """
  Returns the location of the requested element or item.
  """
  def hello(args, _context) do
    "The #{args["name"]} is in the drawer!"
  end
end
