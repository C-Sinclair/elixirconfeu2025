<script>
	export let slides;
</script>

{#each slides as slide}
	<!-- Reminder: using paths means we get the nice code morphing stuff from Reveal.js -->
	<section data-auto-animate data-markdown={slide.path}>
		<p>I am test OK</p>
	</section>
{/each}
