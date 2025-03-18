<script>
	import Slides from '$lib/deck/slides.svelte';

	export let data;
	let slides = data.slides;
</script>

<svelte:head>
	<title>Presentation</title>
</svelte:head>

<Slides {slides} />
