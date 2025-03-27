defmodule ElixirConfEU.LLM.Macros do
  @moduledoc """
  This module provides a macro for registering functions as tools for the LLM.
  """
  alias ElixirConfEU.LLM.Function

  @functions []

  defmacro __using__(_opts) do
    quote do
      @after_compile unquote(__MODULE__)
    end
  end

  defmacro __after_compile__(env, _bytecode) do
    module = env.module
    IO.inspect(module)

    Module.get_attribute(module, :doc)
    |> IO.inspect()

    {:docs_v1, _, _, _, _, _, function_docs} = Code.fetch_docs(module)

    functions = docs_to_funs(function_docs, module)

    Module.put_attribute(__MODULE__, :functions, functions)
  end

  defp docs_to_funs(docs, module) do
    docs
    |> Enum.reduce([], fn
      {{:function, name, _}, _, _,
       %{
         "en" => doc
       }, _acc},
      acc ->
        fun = Function.new!(module, name, doc)
        [fun | acc]

      _, acc ->
        acc
    end)
  end

  def get_functions, do: @functions
end
