defmodule MyModule do
  import LLMMagic

  deftool :foo, """
    Call this function to do a thing
  """ do
    args + 1
  end
end
