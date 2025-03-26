# Alternative LLM Chat models

```elixir [1|1-2|3|4|5|6]
alias LangChain.ChatModels.ChatOpenAI
alias LangChain.ChatModels.ChatAnthropic
alias LangChain.ChatModels.{ChatGoogleAI, ChatVertexAI}
alias LangChain.ChatModels.ChatOllamaAI
alias LangChain.ChatModels.ChatBumblebee
alias LangChain.ChatModels.ChatMistralAI # 🇫🇷
```

---

```elixir [2-5|3|10-14|11-13]
{:ok, _updated_chain} =
  LLMChain.new!(%{
    llm: llm(),
    verbose: true
  })
  ...
  |> LLMChain.run(mode: :while_needs_response)


def llm do
  ChatAnthropic.new!(%{
    model: "claude-3-5-sonnet-20240620"
  })
end
```

Reference: [Langchain docs](https://hexdocs.pm/langchain/readme.html)

