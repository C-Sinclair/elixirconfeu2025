<script>
	import SlideTitle from '$lib/components/SlideTitle.svelte';
	import Code from '$lib/deck/code.svelte';
</script>

<section data-auto-animate>
	<SlideTitle>Doc Comments</SlideTitle>

	<p>
		`@doc` is just another module attribute. Which means it exists at compile time, and we can
		therefore access it at runtime!
	</p>

	<Code lines="14|1|3|4|5|7-13"
		>{@html `{:docs_v1, 
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
} = Code.fetch_docs(module)`}</Code
	>
</section>
