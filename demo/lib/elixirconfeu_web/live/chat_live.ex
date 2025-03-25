defmodule ElixirConfEUWeb.ChatLive do
  use ElixirConfEUWeb, :live_view

  alias ElixirConfEU.Chat
  alias Phoenix.PubSub
  alias Task

  @impl true
  def mount(_params, _session, socket) do
    # Subscribe to LLM responses when the LiveView mounts
    if connected?(socket) do
      PubSub.subscribe(ElixirConfEU.PubSub, "llm:responses")
    end

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

    # Call the LLM module asynchronously using Task
    Task.async(fn ->
      Elixirconfeu.LLM.chat(conversation.id, user_input)
    end)

    {:noreply,
     socket
     |> assign(:current_conversation, conversation)
     |> assign(:messages, messages)
     |> assign(:user_input, "")
     |> assign(:loading, true)}
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
  def handle_info({:llm_response, conversation_id, response}, socket) do
    if socket.assigns.current_conversation &&
         socket.assigns.current_conversation.id == conversation_id do
      messages = Chat.list_messages(conversation_id)

      {:noreply,
       socket
       |> assign(:messages, messages)
       |> assign(:loading, false)}
    else
      {:noreply, socket}
    end
  end

  # Handle Task completion - although we don't need the result since we use PubSub
  @impl true
  def handle_info({ref, _result}, socket) when is_reference(ref) do
    # The task completed successfully so we can demonitor it
    Process.demonitor(ref, [:flush])
    {:noreply, socket}
  end

  # Handle Task failure
  @impl true
  def handle_info({:DOWN, _ref, :process, _pid, reason}, socket) do
    # The task failed
    IO.puts("LLM task failed: #{inspect(reason)}")
    # We could handle the failure here, e.g., by updating the UI
    {:noreply, socket |> assign(:loading, false)}
  end

  defp create_default_conversation do
    {:ok, conversation} = Chat.create_conversation(%{title: "New Conversation"})
    conversation
  end
end
