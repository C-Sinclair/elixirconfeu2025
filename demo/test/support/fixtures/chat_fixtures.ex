defmodule ElixirConfEU.ChatFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ElixirConfEU.Chat` context.
  """

  @doc """
  Generate a conversation.
  """
  def conversation_fixture(attrs \\ %{}) do
    {:ok, conversation} =
      attrs
      |> Enum.into(%{
        title: "some title"
      })
      |> ElixirConfEU.Chat.create_conversation()

    conversation
  end
end
