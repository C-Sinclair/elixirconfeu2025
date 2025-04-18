LLMChain.new!(%{
  llm: claude()
})
|> LLMChain.add_tools(
  LLMMagic.get_functions()
)
|> LLMChain.add_message(
  LangChain.Message.new_user!(user_input)
)
|> LLMChain.run(mode: :while_needs_response)
