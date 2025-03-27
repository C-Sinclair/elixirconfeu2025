defmodule ElixirConfEU.LLM.Macros do
  @moduledoc """
  This module provides a macro for registering functions as tools for the LLM.
  """
  alias LangChain.FunctionParam
  alias ElixirConfEU.LLM.Function

  defmacro __using__(_opts) do
    Module.register_attribute(__CALLER__.module, :params, accumulate: true, persist: true)

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
      {{:function, name, _arity}, _, _,
       %{
         "en" => doc
       }, _acc},
      acc ->
        [doc, params] = parse_doc(doc)
        fun = Function.new!(module, name, doc, params)
        [fun | acc]

      _, acc ->
        acc
    end)
  end

  defp parse_doc(doc) when is_binary(doc) do
    doc
    |> String.split("### Parameters")
    |> parse_doc()
  end

  # case when no params provided
  defp parse_doc([doc]) do
    [doc, nil]
  end

  defp parse_doc([doc, params]) do
    params =
      params
      |> String.split("\n")
      |> Enum.map(&String.trim/1)
      |> Enum.filter(&(&1 != ""))
      |> Enum.map(fn param ->
        case Regex.named_captures(
               ~r/(?<field>\w+):\s*(?<type>:\w+)\s*-\s*(?<description>.+)/,
               param
             ) do
          %{"field" => field, "type" => type, "description" => description} ->
            type = String.to_atom(String.trim_leading(type, ":"))
            description = String.trim(description)

            FunctionParam.new!(%{
              name: field,
              type: type,
              description: description
            })

          nil ->
            nil
        end
      end)

    [doc, params]
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
