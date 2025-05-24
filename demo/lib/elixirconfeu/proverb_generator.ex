defmodule ElixirConfEU.ProverbGenerator do
  use LLMMagic

  @doc """
  Returns a random proverb about Elixir.
  This function selects a random proverb from a predefined list of Elixir-related sayings.
  """
  def random_elixir_proverb(arguments, _context) do
    proverbs = [
      "In Elixir, concurrency is not a feature, it's a way of life.",
      "An Elixir a day keeps the runtime errors away.",
      "When life gives you atoms, make molecules with Elixir.",
      "The phoenix rises, and so does your Elixir app.",
      "Pipe operators: making code flow like a gentle stream.",
      "In the world of Elixir, failure is just another opportunity to supervise.",
      "Pattern matching: Because sometimes, one size doesn't fit all.",
      "Immutability: Changing the world without changing the data.",
      "Why do imperative when you can do functional?",
      "Elixir: Where processes are cheaper than cups of coffee."
    ]

    Enum.random(proverbs)
  end
end