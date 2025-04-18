{:ok, _updated_chain} =
  LLMChain.new!(%{llm: llm()})
  |> LLMChain.add_tool(get_capital_city_tool())
  |> LLMChain.add_message(Message.new_system!("You are an expert geographer"))
  |> LLMChain.add_message(Message.new_user!("What is the capital of France?"))
  |> LLMChain.run(mode: :while_needs_response)
