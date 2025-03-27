defmodule ElixirConfEU.LLM.Macros do
  @moduledoc """
  This module provides a macro for registering functions as tools for the LLM.
  """
  alias ElixirConfEU.LLM.Function

  defmacro __using__(_opts) do
    quote do
      # magic function which is looked for by the LLM to determine if a module is LLM enabled
      def __magic_is_real__ do
        true
      end
    end
  end

  def module_functions(module) do
    {:docs_v1, _, _, _, _, _, function_docs} = Code.fetch_docs(module)

    docs_to_funs(function_docs, module)
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

  def ensure_modules_loaded do
    Application.spec(:elixirconfeu, :modules)
    |> Enum.each(&Code.ensure_loaded/1)
  end

  def get_functions do
    ensure_modules_loaded()

    :code.all_loaded()
    |> Enum.filter(fn {module, _} ->
      Kernel.function_exported?(module, :__magic_is_real__, 0)
    end)
    |> Enum.map(fn {module, _path} -> module end)
    |> Enum.map(&module_functions/1)
    |> List.flatten()
  end
end
