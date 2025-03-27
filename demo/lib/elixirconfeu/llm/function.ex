defmodule ElixirConfEU.LLM.Function do
  @moduledoc """
  This module provides a simple interface for interacting with the LLM using Langchain.
  """
  alias ElixirConfEU.Chat
  alias Phoenix.PubSub

  @spec new!(atom(), atom(), String.t(), Keyword.t() | nil) :: LangChain.Function.t()
  @spec new!(atom(), atom(), String.t()) :: LangChain.Function.t()
  def new!(module, function, description, params \\ nil) do
    name = get_name(module, function)

    LangChain.Function.new!(%{
      name: name,
      description: description,
      params: params,
      function: fn arguments, %{conversation_id: conversation_id} = context ->
        # Create a function call record
        {:ok, function_call} =
          Chat.create_function_call(%{
            module: module,
            function: function,
            parameters: arguments,
            conversation_id: conversation_id
          })

        # broadcast the function call to the client
        notify_liveview(conversation_id)

        # Call the function itself
        result = apply(module, function, [arguments, context])

        # Update the function call with the result
        {:ok, _function_call} =
          Chat.complete_function_call(function_call, result)

        notify_liveview(conversation_id)

        result
      end
    })
  end

  def get_name(module, function) when is_atom(module) do
    module
    |> Module.split()
    |> Enum.join("_")
    |> get_name(function)
  end

  def get_name(module, function) when is_binary(module) do
    module
    |> Kernel.<>("_#{function}")
    |> String.downcase()
  end

  defp notify_liveview(conversation_id) do
    PubSub.broadcast(
      ElixirConfEU.PubSub,
      "llm:responses",
      {:llm_response, conversation_id}
    )
  end
end
