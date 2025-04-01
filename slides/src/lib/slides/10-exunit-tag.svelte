<script>
	import SlideTitle from '$lib/components/SlideTitle.svelte';
	import Code from '$lib/deck/code.svelte';
</script>

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

	<p>`@tag` in ExUnit is just a plain old module attribute</p>

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
