<script>
	import SlideTitle from '$lib/components/SlideTitle.svelte';
</script>

<section data-auto-animate>
	<SlideTitle>Extracting Docs and Functions</SlideTitle>

	<p>
		We want 1 module which will hold compile-time state and add any functions we provide to that
		state.
	</p>

	<p>So then at runtime, those functions will be made available to the LLM Chain as Tools.</p>
</section>
