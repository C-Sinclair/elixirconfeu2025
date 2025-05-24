defmodule ElixirConfEU.SuccessConfetti do
  use LLMMagic
  alias Phoenix.PubSub

  @doc """
  Checks if the input contains the word "success" (case-insensitive) and triggers confetti if it does.
  Returns a string indicating whether confetti was triggered or not.
  """
  def trigger_on_success(arguments, _context) do
    input = arguments["input"] || ""
    if String.match?(String.downcase(input), ~r/success/) do
      PubSub.broadcast(ElixirConfEU.PubSub, "llm:responses", {:confetti})
      "Success mentioned! Confetti triggered! 🎉"
    else
      "No mention of success. Confetti not triggered."
    end
  end
end