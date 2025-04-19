defmodule ElixirConfEUWeb.ConversationLive.Form do
  use ElixirConfEUWeb, :live_view

  alias ElixirConfEU.Chat
  alias ElixirConfEU.Chat.Conversation

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage conversation records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="conversation-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:title]} type="text" label="Title" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Conversation</.button>
          <.button navigate={return_path(@return_to, @conversation)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    conversation = Chat.get_conversation!(id)

    socket
    |> assign(:page_title, "Edit Conversation")
    |> assign(:conversation, conversation)
    |> assign(:form, to_form(Chat.change_conversation(conversation)))
  end

  defp apply_action(socket, :new, _params) do
    conversation = %Conversation{}

    socket
    |> assign(:page_title, "New Conversation")
    |> assign(:conversation, conversation)
    |> assign(:form, to_form(Chat.change_conversation(conversation)))
  end

  @impl true
  def handle_event("validate", %{"conversation" => conversation_params}, socket) do
    changeset = Chat.change_conversation(socket.assigns.conversation, conversation_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"conversation" => conversation_params}, socket) do
    save_conversation(socket, socket.assigns.live_action, conversation_params)
  end

  defp save_conversation(socket, :edit, conversation_params) do
    case Chat.update_conversation(socket.assigns.conversation, conversation_params) do
      {:ok, conversation} ->
        {:noreply,
         socket
         |> put_flash(:info, "Conversation updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, conversation))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_conversation(socket, :new, conversation_params) do
    case Chat.create_conversation(conversation_params) do
      {:ok, conversation} ->
        {:noreply,
         socket
         |> put_flash(:info, "Conversation created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, conversation))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _conversation), do: ~p"/conversations"
  defp return_path("show", conversation), do: ~p"/conversations/#{conversation}"
end
