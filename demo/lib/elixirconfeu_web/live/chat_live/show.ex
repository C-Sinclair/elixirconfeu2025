defmodule ElixirConfEUWeb.ChatLive.Show do
  use ElixirConfEUWeb, :live_view

  alias ElixirConfEU.Chat
  alias ElixirConfEU.Chat.{Conversation, FunctionCall, Message}
  alias Phoenix.PubSub

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    # Subscribe to LLM responses when the LiveView mounts
    if connected?(socket) do
      PubSub.subscribe(ElixirConfEU.PubSub, "llm:responses")
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Conversation")
     |> assign(:user_input, "")
     |> assign(:loading, false)
     |> assign(:conversation, Chat.get_conversation!(id))}
  end

  @impl true
  def handle_event(
        "submit_message",
        %{"user_input" => user_input},
        %{assigns: %{conversation: conversation}} = socket
      ) do
    {:ok, message} =
      Chat.create_message(%{
        content: user_input,
        role: "user",
        conversation_id: conversation.id
      })

    # Start an independent supervised task that will survive navigation
    Task.Supervisor.async_nolink(ElixirConfEU.TaskSupervisor, fn ->
      ElixirConfEU.LLM.chat(conversation.id, user_input)
    end)

    messages = conversation.messages ++ [message]
    conversation = %Conversation{conversation | messages: messages}

    {:noreply,
     socket
     |> assign(:conversation, conversation)
     |> assign(:user_input, "")
     |> assign(:loading, true)}
  end

  @impl true
  def handle_info({:llm_response, conversation_id}, socket) do
    if socket.assigns.conversation &&
         socket.assigns.conversation.id == conversation_id do
      conversation = Chat.get_conversation!(conversation_id)

      {:noreply,
       socket
       |> assign(:conversation, conversation)
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

  # Handle Task failure from supervised task
  @impl true
  def handle_info({:DOWN, _ref, :process, _pid, reason}, socket) do
    # The task failed
    IO.puts("LLM task failed: #{inspect(reason)}")
    # We could handle the failure here, e.g., by updating the UI
    {:noreply, socket |> assign(:loading, false)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="flex-1 p-4 overflow-y-auto">
        <div class="space-y-4">
          <.chat_item :for={item <- ordered_items(@conversation)} item={item} />
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

  defp chat_item(
         %{
           item: %FunctionCall{
             module: module,
             function: function
           }
         } = assigns
       ) do
    source = get_function_source(module, function)

    assigns =
      assigns
      |> assign(:source, source)

    ~H"""
    <div class="flex flex-col gap-2 py-2 rounded-md text-sm">
      <div class="font-mono text-blue-400">
        {@item.module}.{@item.function}/1
      </div>
      <div :if={@item.parameters && is_map(@item.parameters)} class="">
        <div class="font-semibold text-xs">Parameters:</div>
        <pre class="text-xs p-1 rounded"><%= Jason.encode!(@item.parameters, pretty: true) %></pre>
      </div>
      <div :if={@item.result} class="">
        <div class="font-semibold text-xs">Result:</div>
        <pre class="text-xs p-1 rounded"><%= @item.result %></pre>
      </div>
      <div :if={@source} class="mockup-code w-full">
        <pre><code><%= @source %></code></pre>
      </div>
    </div>
    """
  end

  defp get_function_source("[MCP]", _), do: nil

  defp get_function_source(module, function) when is_binary(module) do
    IO.puts("module: #{module}")
    module = String.to_existing_atom(module)
    get_function_source(module, function)
  end

  defp get_function_source(module, function) when is_binary(function) do
    get_function_source(module, String.to_atom(function))
  end

  defp get_function_source(module, function) when is_atom(module) and is_atom(function) do
    try do
      # Get the beam file location
      beam_file = :code.which(module)

      # Get the source file from the debug info
      {:ok, {_, [{:abstract_code, {_, abstract_code}}]}} =
        :beam_lib.chunks(beam_file, [:abstract_code])

      # Find the function definition in the abstract code
      case Enum.find(abstract_code, fn
             {:function, _, ^function, _, _} -> true
             _ -> false
           end) do
        {:function, _, _, _, clauses} ->
          # Convert the abstract format back to string
          clauses
          |> Enum.map_join("\n", fn clause ->
            ~c"#{:erl_pp.form(clause)}"
            |> to_string()
            # Remove the function header
            |> String.replace(~r/^function.*->\s*/, "")
            # Normalize whitespace
            |> String.replace(~r/\s+/, " ")
          end)

        _ ->
          "Function source not found"
      end
    rescue
      _ -> "Could not fetch function source"
    end
  end
end
