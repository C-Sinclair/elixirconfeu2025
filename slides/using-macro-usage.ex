defmodule MyModule do
  use LLMMagic

  @doc "Call this function with a number to add one to it"
  def foo(args, context) do
    args + 1
  end
end
