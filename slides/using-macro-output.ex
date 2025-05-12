defmodule MyModule do
  # magic function which is looked for by the LLM to determine if a module is LLM enabled
  def __magic_is_real__ do
    true
  end

  @doc "Call this function with a number to add one to it"
  def foo(args, context) do
    args + 1
  end
end
