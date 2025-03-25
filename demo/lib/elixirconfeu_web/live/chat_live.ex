defmodule ElixirConfEUWeb.ChatLive do
  use ElixirConfEUWeb, :live_view

  alias ElixirConfEU.Chat
  alias ElixirConfEU.Chat.{Conversation, Message, FunctionCall}
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
     |> assign(:user_input, "")
     |> assign(:loading, false)}
  end

  @impl true
  def handle_params(%{"id" => id}, _uri, socket) do
    conversation = Chat.get_conversation!(id)

    {:noreply,
     socket
     |> assign(:current_conversation, conversation)}
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

    # Call the LLM module asynchronously using Task
    Task.async(fn ->
      ElixirConfEU.LLM.chat(conversation.id, user_input)
    end)

    messages = conversation.messages ++ [message]
    conversation = %Conversation{conversation | messages: messages}

    {:noreply,
     socket
     |> assign(:current_conversation, conversation)
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
  def handle_info({:llm_response, conversation_id, _response}, socket) do
    if socket.assigns.current_conversation &&
         socket.assigns.current_conversation.id == conversation_id do
      conversation = Chat.get_conversation!(conversation_id)

      {:noreply,
       socket
       |> assign(:current_conversation, conversation)
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

  defp ordered_items(conversation) do
    conversation.messages
    |> Enum.concat(conversation.function_calls)
    |> Enum.sort_by(& &1.inserted_at, :asc)
  end

  defp chat_item(%{item: %Message{}} = assigns) do
    ~H"""
    <div class="py-4 max-w-3xl">
      <div class={if @item.role == "user", do: "text-4xl", else: ""}>
        {@item.content}
      </div>
    </div>
    """
  end

  defp chat_item(%{item: %FunctionCall{}} = assigns) do
    ~H"""
    <div class="flex flex-col gap-2 py-2 rounded-md text-sm">
      <div class="font-mono text-blue-400">
        {@item.module}.{@item.function}/1
      </div>
      <div class="">
        <div class="font-semibold text-xs">Parameters:</div>
        <pre class="text-xs p-1 rounded"><%= Jason.encode!(@item.parameters, pretty: true) %></pre>
      </div>
      <div :if={@item.result} class="">
        <div class="font-semibold text-xs">Result:</div>
        <pre class="text-xs p-1 rounded"><%= @item.result %></pre>
      </div>
    </div>
    """
  end
end
