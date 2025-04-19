defmodule ElixirConfEUWeb.ConversationLive.Show do
  use ElixirConfEUWeb, :live_view

  alias ElixirConfEU.Chat

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Conversation {@conversation.id}
        <:subtitle>This is a conversation record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/conversations"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/conversations/#{@conversation}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit conversation
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Title">{@conversation.title}</:item>
      </.list>
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
end
