defmodule ElixirConfEUWeb.ChatLive.Index do
  use ElixirConfEUWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="py-4 flex flex-col justify-center flex-1 pb-32">
        <div class="flex justify-center items-center mb-8">
          <div class="text-4xl">
            What do you want to know?
          </div>
        </div>
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
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "ElixirConfEU Chat")}
  end
end
