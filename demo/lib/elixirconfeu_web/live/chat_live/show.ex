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
      ElixirConfEU.LLM.chat(conversation.id)
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

  def handle_info({:confetti}, socket) do
    {:noreply, push_event(socket, "confetti", %{particleCount: 500, spread: 360})}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div id="chat-root" phx-hook="Confetti">
      <div class="flex-1 p-4">
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
    <div class="py-4 max-w-3xl" phx-hook="ScrollToBottom" id={"message-#{@item.id}"}>
      <div class={if @item.role == "user", do: "text-4xl", else: ""}>
        {@item.content}
      </div>
    </div>
    """
  end

  defp chat_item(
         %{
           item: %FunctionCall{
             module: "[MCP]"
           }
         } = assigns
       ) do
    ~H"""
    <div class="flex flex-col gap-2 py-2 rounded-md text-sm" phx-hook="ScrollToBottom" id={"message-#{@item.id}"}>
      <div class="font-mono text-blue-400">
        {@item.module} {@item.function}
      </div>
      <div :if={@item.parameters && is_map(@item.parameters)} class="">
        <div class="font-semibold text-xs">Parameters:</div>
        <.parameters_table parameters={@item.parameters} />
      </div>
      <.results item={@item} />
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
    <div class="flex flex-col gap-4 py-2 rounded-md text-sm" phx-hook="ScrollToBottom" id={"message-#{@item.id}"}>
      <div class="font-mono text-info flex items-center gap-2">
        <.icon name="hero-code-bracket" class="w4 h-4" />
        {String.trim_leading(@item.module, "Elixir.")}.{@item.function}/1
      </div>
      <div :if={@item.parameters && is_map(@item.parameters)} class="">
        <div class="font-semibold text-xs">Parameters:</div>
        <.parameters_table parameters={@item.parameters} />
      </div>
      <div
        :if={@source}
        class="mockup-code w-full bg-[#1e1e2e]"
        id={"source-#{@item.id}"}
        phx-update="ignore"
        phx-hook="Highlight"
        data-source={@source}
      >
      </div>
      <.results item={@item} />
    </div>
    """
  end

  defp results(assigns) do
    ~H"""
    <div :if={@item.result} class="bg-success/10 rounded-box px-4 py-6 w-3xl">
      <div class="flex items-center gap-3">
        <.icon name="hero-check-circle" class="w-5 h-5 text-success" />
        <pre class="text-sm font-bold w-full overflow-hidden"><%= @item.result |> String.trim_leading("\"") |> String.trim_trailing("\"") %></pre>
      </div>
    </div>
    """
  end

  defp parameters_table(assigns) do
    ~H"""
    <table class="table">
      <thead>
        <tr>
          <th>Key</th>
          <th>Value</th>
        </tr>
      </thead>
      <tbody>
        <tr :for={{key, value} <- @parameters}>
          <td class="w-8">{key}</td>
          <td class="w-24">{inspect(value)}</td>
        </tr>
      </tbody>
    </table>
    """
  end

  defp get_function_source("[MCP]", _), do: nil

  defp get_function_source(module, function) when is_binary(module) do
    module = String.to_existing_atom(module)
    get_function_source(module, function)
  end

  defp get_function_source(module, function) when is_binary(function) do
    get_function_source(module, String.to_atom(function))
  end

  defp get_function_source(module, function) when is_atom(module) and is_atom(function) do
    try do
      IO.inspect({module, function}, label: "Module and function")

      # Get the beam file location
      beam_file = :code.which(module)
      IO.inspect(beam_file, label: "Beam file location")

      case beam_to_source_file(beam_file) do
        {:ok, source_file} ->
          IO.inspect(source_file, label: "Found source file")
          # Read the source file
          case File.read(source_file) do
            {:ok, source} ->
              # Find the function definition
              result =
                source
                |> String.split("\n")
                |> extract_function(function)

              IO.inspect(result, label: "Extraction result")

              result
              |> String.trim()

            err ->
              IO.inspect(err, label: "File read error")
              nil
          end

        err ->
          IO.inspect(err, label: "Source file not found")
          nil
      end
    rescue
      e ->
        IO.inspect(e, label: "Error retrieving source")
        nil
    end
  end

  defp extract_function(lines, function) do
    # First find the starting line of our target function
    {start_index, doc_lines} =
      Enum.with_index(lines)
      |> Enum.reduce_while({nil, []}, fn
        {line, idx}, {nil, acc} ->
          cond do
            # Found the function definition
            String.match?(line, ~r/^  def #{function}.*do$/) ->
              # Look back for doc string
              preceding_lines = Enum.take(lines, idx)

              doc_start_idx =
                Enum.find_index(Enum.reverse(preceding_lines), fn l ->
                  String.match?(l, ~r/^  @doc/)
                end)

              if doc_start_idx do
                actual_idx = length(preceding_lines) - doc_start_idx - 1
                doc_lines = Enum.slice(lines, actual_idx..(idx - 1))
                {:halt, {idx, doc_lines}}
              else
                {:halt, {idx, []}}
              end

            true ->
              {:cont, {nil, acc}}
          end
      end)

    case start_index do
      nil ->
        "Function source not found"

      idx ->
        # Now collect lines until we find the matching end
        # Keep track of nested do/end blocks
        {result, _} =
          lines
          |> Enum.drop(idx)
          |> Enum.reduce_while({[], 0}, fn line, {acc, depth} ->
            new_depth =
              cond do
                # Increase depth for do blocks
                String.match?(line, ~r/.*do\s*$/) -> depth + 1
                # Decrease depth for end blocks
                String.match?(line, ~r/^  end/) && depth > 0 -> depth - 1
                true -> depth
              end

            if new_depth == 0 && String.match?(line, ~r/^  end/) do
              {:halt, {[line | acc], new_depth}}
            else
              {:cont, {[line | acc], new_depth}}
            end
          end)

        (doc_lines ++ Enum.reverse(result))
        |> Enum.join("\n")
        |> String.trim()
    end
  end

  defp beam_to_source_file(beam_file) do
    module_path =
      beam_file
      |> Path.basename(".beam")
      |> String.replace_prefix("Elixir.", "")
      |> String.split(".")
      |> Enum.map(&Macro.underscore/1)
      |> Enum.join("/")
      |> String.replace("elixir_conf_eu", "elixirconfeu")
      |> Kernel.<>(".ex")

    IO.inspect(module_path, label: "Module path")

    # Try relative to beam file first
    source_path =
      beam_file
      |> Path.dirname()
      |> Path.join("../lib")
      |> Path.expand()
      |> Path.join(module_path)

    IO.inspect(source_path, label: "Trying source path")

    if File.exists?(source_path) do
      {:ok, source_path}
    else
      # Try looking in the current project's lib directory
      alt_path = Path.join([File.cwd!(), "lib", module_path])
      IO.inspect(alt_path, label: "Trying alternative path")
      if File.exists?(alt_path), do: {:ok, alt_path}, else: :error
    end
  end
end
