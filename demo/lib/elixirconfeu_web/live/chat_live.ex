defmodule ElixirConfEUWeb.ChatLive do
  use ElixirConfEUWeb, :live_view

  alias ElixirConfEU.Chat

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:current_conversation, nil)
     |> assign(:messages, [])
     |> assign(:user_input, "")
     |> assign(:loading, false)}
  end

  @impl true
  def handle_params(%{"id" => id}, _uri, socket) do
    conversation = Chat.get_conversation!(id)
    messages = Chat.list_messages(conversation.id)

    {:noreply,
     socket
     |> assign(:current_conversation, conversation)
     |> assign(:messages, messages)}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("submit_message", %{"user_input" => user_input}, socket) do
    conversation = socket.assigns.current_conversation || create_default_conversation()

    {:ok, message} =
      Chat.create_message(%{
        content: user_input,
        role: "user",
        conversation_id: conversation.id
      })

    messages = Chat.list_messages(conversation.id)

    # TODO: Call the LLM here

    {:noreply,
     socket
     |> assign(:current_conversation, conversation)
     |> assign(:messages, messages)
     |> assign(:user_input, "")
     |> assign(:loading, true)
     |> push_event("simulate_llm_response", %{message_id: message.id})}
  end

  @impl true
  def handle_event("create_conversation", _params, socket) do
    {:ok, conversation} = Chat.create_conversation(%{title: "New Conversation"})

    {:noreply,
     socket
     |> push_navigate(to: ~p"/chat/#{conversation.id}")}
  end

  @impl true
  def handle_event("select_conversation", %{"id" => id}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/chat/#{id}")}
  end

  @impl true
  def handle_event("simulate_llm_response", %{"message_id" => message_id}, socket) do
    # This is just a simulation - in a real app, you'd receive a response from your LLM service

    {:ok, assistant_message} =
      Chat.create_message(%{
        content: "This is a simulated response from the assistant.",
        role: "assistant",
        conversation_id: socket.assigns.current_conversation.id
      })

    # Simulate a function call
    {:ok, _function_call} =
      Chat.create_function_call(%{
        function_name: "example_function",
        parameters: %{param1: "value1", param2: "value2"},
        result: "Function result example",
        status: "complete",
        message_id: assistant_message.id
      })

    messages = Chat.list_messages(socket.assigns.current_conversation.id)

    {:noreply,
     socket
     |> assign(:messages, messages)
     |> assign(:loading, false)}
  end

  defp create_default_conversation do
    {:ok, conversation} = Chat.create_conversation(%{title: "New Conversation"})
    conversation
  end
end
