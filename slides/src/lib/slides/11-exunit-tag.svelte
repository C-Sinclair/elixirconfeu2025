<script>
	import SlideTitle from '$lib/components/SlideTitle.svelte';
	import Code from '$lib/deck/code.svelte';
</script>

<section data-auto-animate>
	<SlideTitle>Module Attributes</SlideTitle>

	<p>`@tag` in ExUnit is just a plain old module attribute</p>

	<Code
		>{`@tag :my_tag
test "a test which does a thing" do
    ...
end`}</Code
	>
</section>

<section data-auto-animate>
	<SlideTitle>Module Attributes</SlideTitle>

	<p>`@tag` in ExUnit is just a plain old module attribute</p>

	<Code
		>{`@tag :my_tag
test "a test which does a thing" do
    ...
end`}</Code
	>

	<p>Hottip 🔥</p>

	<Code>{`mix test --only my_tag`}</Code>
</section>
