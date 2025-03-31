<script>
	import SlideTitle from '$lib/components/SlideTitle.svelte';
	import Code from '$lib/deck/code.svelte';
</script>

<section data-auto-animate>
	<SlideTitle>Alternative LLM Chat models</SlideTitle>

	<Code
		lines="1|1-2|3|4|5|6"
		code={`alias LangChain.ChatModels.ChatOpenAI
alias LangChain.ChatModels.ChatAnthropic
alias LangChain.ChatModels.{ChatGoogleAI, ChatVertexAI}
alias LangChain.ChatModels.ChatOllamaAI
alias LangChain.ChatModels.ChatBumblebee
alias LangChain.ChatModels.ChatMistralAI # 🇫🇷`}
	/>
</section>

<section data-auto-animate>
	<Code
		lines="2-5|3|10-14|11-13"
		code={`{:ok, _updated_chain} =
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
end`}
	/>

	<p>Reference: <a href="https://hexdocs.pm/langchain/readme.html">Langchain docs</a></p>
</section>
