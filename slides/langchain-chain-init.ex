{:ok, _updated_chain} =
  LLMChain.new!(%{
    llm: llm(),
    verbose: true
  })
  # ...
  |> LLMChain.run(mode: :while_needs_response)

def llm do
  ChatAnthropic.new!(%{
    model: "claude-3-5-sonnet-20240620"
  })
end
