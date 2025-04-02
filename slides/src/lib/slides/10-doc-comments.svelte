<script>
	import SlideTitle from '$lib/components/SlideTitle.svelte';
	import Code from '$lib/deck/code.svelte';
</script>

<section data-auto-animate>
	<SlideTitle>Doc Comments</SlideTitle>

	<p>
		<code>@doc</code> is just another module attribute. A special compile time attribute that can be
		accessed at runtime!
	</p>

	<Code
		id="fetch-docs"
		lines="2"
		code={`
{:docs_v1, ...}
= Code.fetch_docs(module)`}
	/>
</section>

<section data-auto-animate>
	<SlideTitle>Doc Comments</SlideTitle>

	<p>
		<code>@doc</code> is just another module attribute. A special compile time attribute that can be
		accessed at runtime!
	</p>

	<Code
		id="fetch-docs"
		lines="14|1|3|4|5|7-13"
		code={`
{:docs_v1, 
 _,
 :elixir, 
 "text/markdown", 
 %{"en" => @moduledoc}, 
 _, 
 [{
    {:function, :foo, _arity}, 
    _, 
    _, 
    %{"en" => @doc}, 
    _
  }]
} = Code.fetch_docs(module)`}
	/>
</section>
