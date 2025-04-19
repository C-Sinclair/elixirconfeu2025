defmodule ElixirConfEUWeb.ChatLive.Show do
  use ElixirConfEUWeb, :live_view

  alias ElixirConfEU.Chat

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="flex-1 p-4 overflow-y-auto">
        <div class="space-y-4">
          <.chat_item :for={item <- ordered_items(@current_conversation)} item={item} />
        </div>
      </div>

      <div class="py-4 flex flex-col justify-center">
        <form
          phx-submit="submit_message"
          class="flex rounded-lg pr-2 py-2 space-x-2 border border-[--border-color] rounded-md focus-within:border-blue-500 focus-within:ring-1 focus-within:ring-blue-500"
        >
          <input
            type="text"
            name="user_input"
            value={@user_input}
            placeholder="Ask me anything..."
            class="flex-1"
            autocomplete="off"
            disabled={@loading}
          />
          <button
            type="submit"
            class={"bg-gray-700 text-white px-4 py-2 rounded-sm hover:bg-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-500 #{if @loading, do: "opacity-50 cursor-not-allowed"}"}
            disabled={@loading}
          >
            Send
          </button>
        </form>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Conversation")
     |> assign(:conversation, Chat.get_conversation!(id))}
  end

  @impl true
  def handle_event("submit_message", %{"user_input" => user_input}, socket) do
    conversation = socket.assigns.current_conversation || create_default_conversation()

    # If this is a new conversation, update the URL
    socket =
      if socket.assigns.current_conversation == nil do
        push_patch(socket, to: ~p"/chat/#{conversation.id}")
      else
        socket
      end

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
  def handle_info({:llm_response, conversation_id}, socket) do
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
