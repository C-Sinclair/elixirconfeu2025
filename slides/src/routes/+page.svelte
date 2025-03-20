<script>
	import Slides from '$lib/deck/slides.svelte';

	export let data;
	let slides = data.slides;
</script>

<svelte:head>
	<title>Presentation</title>
</svelte:head>

<Slides {slides} />

<iframe
	src="http://localhost:4000/iframe"
	title="Demo"
	sandbox="allow-same-origin allow-scripts allow-forms allow-popups allow-popups-to-escape-sandbox allow-modals allow-top-navigation"
	loading="lazy"
	referrerpolicy="no-referrer"
	style="width:100%;height:50vh"
>
</iframe>

<style>
	:global(body:has(.present [data-demo])) iframe {
		display: none;
	}
</style>
