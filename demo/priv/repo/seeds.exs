# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ElixirConfEU.Repo.insert!(%ElixirConfEU.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias ElixirConfEU.Chat.{Conversation, Message, FunctionCall}
alias ElixirConfEU.Repo

# Create initial conversation
conversation =
  Repo.insert!(%Conversation{
    title: "Welcome to ElixirConf EU 2025!"
  })

# Add welcome message
Repo.insert!(%Message{
  content: "Hello! I'm your AI assistant for ElixirConf EU 2025. How can I help you today?",
  role: "assistant",
  conversation_id: conversation.id
})

# Add example function call
Repo.insert!(%FunctionCall{
  module: "ElixirConfEU.Greeter",
  function: "welcome",
  parameters: %{
    "name" => "ElixirConf EU",
    "year" => 2025
  },
  result: "Welcome to ElixirConf EU 2025! We're excited to have you here.",
  status: "complete",
  conversation_id: conversation.id
})
