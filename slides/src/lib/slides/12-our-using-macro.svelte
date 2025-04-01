<script>
	import SlideTitle from '$lib/components/SlideTitle.svelte';
	import Code from '$lib/deck/code.svelte';
</script>

<section data-auto-animate>
	<header>
		<SlideTitle>Our Using Macro</SlideTitle>
		<h2>Implementation</h2>
	</header>

	<Code
		code={`
defmacro __using__(_opts) do
    Module.register_attribute(__CALLER__.module, :params, accumulate: true, persist: true)

    quote do
		# magic function which is looked for by the LLM to determine if a module is LLM enabled
		def __magic_is_real__ do
			true
		end
    end
end
`}
	/>
</section>

<section data-auto-animate>
	<header>
		<SlideTitle>Our Using Macro</SlideTitle>
		<h2>Usage</h2>
	</header>

	<Code
		code={`
defmodule MyModule do
  use LLMMagic

  @doc "Call this function to do a thing"
  def foo(x) do
    x + 1
  end
end
`}
	/>
</section>

<section data-auto-animate>
	<header>
		<SlideTitle>Our Using Macro</SlideTitle>
		<h2>Runtime</h2>
	</header>

	<Code
		code={`
def get_functions do
	# ensure_modules_loaded
	Application.spec(:elixirconfeu, :modules)
    |> Enum.each(&Code.ensure_loaded/1)

	:code.all_loaded()
	|> Enum.filter(fn {module, _} ->
		Kernel.function_exported?(module, :__magic_is_real__, 0)
	end)
	|> Enum.map(fn {module, _path} -> module end)
	|> Enum.map(&module_functions/1)
	|> List.flatten()
end
`}
	/>
</section>

<section data-auto-animate>
	<header>
		<SlideTitle>Our Using Macro</SlideTitle>
		<h2>Runtime</h2>
	</header>

	<Code
		code={`
def module_functions(module) do
	{:docs_v1, _, _, _, _, _, function_docs} = Code.fetch_docs(module)

	# ... a bunch of unwrapping of the data 
	
	LangChain.Function.new!(%{
      name: name,
      description: description,
      params: params,
      function: fn arguments, context ->
        # Call the module function itself
		apply(module, function, [arguments, context])
      end
    }) 
end
`}
	/>
</section>

<section data-auto-animate>
	<header>
		<SlideTitle>Our Using Macro</SlideTitle>
		<h2>Runtime</h2>
	</header>

	<Code
		code={`
LLMChain.new!(%{
	llm: claude(),
})
|> LLMChain.add_tools(
	ElixirConfEU.LLM.Macros.get_functions()
)
|> LLMChain.add_message(
	LangChain.Message.new_user!(user_input)
)
|> LLMChain.run(mode: :while_needs_response)
`}
	/>
</section>
