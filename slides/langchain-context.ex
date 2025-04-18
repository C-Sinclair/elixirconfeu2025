# map of data we want to be passed as \`context\` to the function when
# executed.
custom_context = %{
  "user_id" => 123,
  "hairbrush" => "drawer",
  "dog" => "backyard",
  "sandwich" => "kitchen"
}

# create and run the chain
{:ok, updated_chain} =
  LLMChain.new!(%{
    llm: llm(),
    custom_context: custom_context,
    verbose: true
  })
  |> LLMChain.add_tools(custom_fn)
  |> LLMChain.add_message(Message.new_user!("Where is the hairbrush located?"))
  |> LLMChain.run(mode: :while_needs_response)

# print the LLM's answer
IO.puts(ChainResult.to_string!(updated_chain))
# => "The hairbrush is located in the drawer."
