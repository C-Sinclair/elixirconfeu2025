<script>
	export let slides;
</script>

{#each slides as slide, i}
	<section data-auto-animate>
		<svelte:component this={slide.default} />
	</section>
{/each}
