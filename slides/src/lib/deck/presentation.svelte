<script>
	import Code from './code.svelte';
	import Notes from './notes.svelte';

	// import all markdown files from slides directory
	const slides = import.meta.glob('$lib/slides/*.md');

	// order by file name
	const slideKeys = Object.keys(slides).sort((a, b) => a.localeCompare(b));
</script>

{#each slideKeys as slideKey}
	<section data-auto-animate data-markdown={slideKey}></section>
{/each}
