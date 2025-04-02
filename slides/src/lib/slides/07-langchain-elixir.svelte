<script>
	import SlideTitle from '$lib/components/SlideTitle.svelte';
	import Code from '$lib/deck/code.svelte';
</script>

<section data-auto-animate>
	<SlideTitle>Langchain for Elixir</SlideTitle>
	<p>A library for interacting with LLMs</p>
</section>

<section data-auto-animate>
	<header>
		<SlideTitle>Langchain for Elixir</SlideTitle>
		<h2>A basic example</h2>
	</header>

	<Code
		code={`
{:ok, _updated_chain} =
  LLMChain.new!(%{ llm: llm() })
  |> LLMChain.add_tool(
    Function.new!(%{
      name: "get_capital",
      description: "Returns the capital of the requested country.",
      parameters_schema: %{
        type: "object",
        properties: %{
          country: %{
            type: "string",
            description: "The country to get the capital of."
          }
        },
        required: ["country"]
      }
    })
  )
  |> LLMChain.add_message(Message.new_system!("You are an expert geographer"))
  |> LLMChain.add_message(Message.new_user!("What is the capital of France?"))
  |> LLMChain.run(mode: :while_needs_response)
`}
	/>

	<p>Reference: <a href="https://hexdocs.pm/langchain/readme.html">Langchain docs</a></p>
</section>

<section data-auto-animate>
	<header>
		<SlideTitle>Langchain for Elixir</SlideTitle>
		<h2>LLM Chat models</h2>
	</header>

	<Code
		lines="2-5|3|10-14|11-13"
		code={`
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
end`}
	/>

	<p>Reference: <a href="https://hexdocs.pm/langchain/readme.html">Langchain docs</a></p>
</section>

<section data-auto-animate>
	<header>
		<SlideTitle>Langchain for Elixir</SlideTitle>
		<h2>Alternative LLM Chat models</h2>
	</header>

	<Code
		lines="1|1-2|3|4|5|6"
		code={`
alias LangChain.ChatModels.ChatOpenAI
alias LangChain.ChatModels.ChatAnthropic
alias LangChain.ChatModels.{ChatGoogleAI, ChatVertexAI}
alias LangChain.ChatModels.ChatOllamaAI
alias LangChain.ChatModels.ChatBumblebee
alias LangChain.ChatModels.ChatMistralAI # 🇫🇷`}
	/>
</section>

<section data-auto-animate>
	<header>
		<SlideTitle>Langchain for Elixir</SlideTitle>
		<h2>Providing context</h2>
	</header>

	<Code
		lines
		code={`
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
`}
	/>

	<p>Reference: <a href="https://hexdocs.pm/langchain/readme.html">Langchain docs</a></p>
</section>

<section data-auto-animate>
	<header>
		<SlideTitle>Langchain for Elixir</SlideTitle>
		<h2>Defining a custom function</h2>
	</header>
	<Code
		lines
		code={`
  Function.new!(%{
    name: "custom",
    description: "Returns the location of the requested element or item.",
    parameters_schema: %{
      type: "object",
      properties: %{
        thing: %{
          type: "string",
          description: "The thing whose location is being requested."
        }
      },
      required: ["thing"]
    },
    function: fn %{"thing" => thing} = _arguments, context ->
      # our context is a pretend item/location location map
      {:ok, context[thing]}
    end
  })
`}
	/>
</section>
