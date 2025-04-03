<script>
	import SlideTitle from '$lib/components/SlideTitle.svelte';
	import Code from '$lib/deck/code.svelte';
</script>

<section data-auto-animate>
	<SlideTitle centred>And now for something completely different...</SlideTitle>
</section>

<section data-auto-animate>
	<SlideTitle>What is a macro?</SlideTitle>

	<p>
		Macros let you write code that writes code—transforming Elixir at compile time using its AST.
	</p>
</section>

<section data-auto-animate>
	<SlideTitle>AST representation</SlideTitle>
</section>

<section data-auto-animate>
	<SlideTitle>Simple example macro</SlideTitle>
	<p>You now know metaprogramming!</p>
</section>

<section data-auto-animate>
	<SlideTitle>Macros</SlideTitle>
	<p>You now know metaprogramming!</p>
</section>

<section data-auto-animate>
	<SlideTitle>Accumulation</SlideTitle>

	<p>We can use module attributes to store compile-time state that can be accessed at runtime!</p>
</section>
<section data-auto-animate>
	<SlideTitle>Module Attributes</SlideTitle>

	<p><code>@tag</code> in ExUnit is just a plain old module attribute</p>

	<Code
		code={`
@tag :my_tag
test "a test which does a thing" do
    ...
end
`}
	/>
</section>

<section data-auto-animate>
	<SlideTitle>Module Attributes</SlideTitle>

	<p><code>@tag</code> in ExUnit is just a plain old module attribute</p>

	<Code
		code={`
@tag :my_tag
test "a test which does a thing" do
    ...
end`}
	/>

	<p>Hottip 🔥</p>

	<Code code={`mix test --only my_tag`} lang="bash" />
</section>
