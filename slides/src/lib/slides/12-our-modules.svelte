<script>
	import SlideTitle from '$lib/components/SlideTitle.svelte';
	import Code from '$lib/deck/code.svelte';
</script>

<section data-auto-animate>
	<header>
		<SlideTitle>Our Modules</SlideTitle>
		<h2>Implementation</h2>
	</header>

	<p>Our modules are a bit more complex than the simple example we saw earlier.</p>

	<p>
		I've gone through and implemented a few different interesting features, and with a single line,
		added a new tool to the LLM!
	</p>

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

<!-- TODO: Add more examples -->
