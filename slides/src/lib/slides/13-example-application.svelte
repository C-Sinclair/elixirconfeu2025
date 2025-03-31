<script>
	import SlideTitle from '$lib/components/SlideTitle.svelte';
</script>

<section data-auto-animate>
	<SlideTitle>Demo time</SlideTitle>

	<iframe
		src="http://localhost:4000/iframe"
		title="Demo"
		sandbox="allow-same-origin allow-scripts allow-forms allow-popups allow-popups-to-escape-sandbox allow-modals allow-top-navigation"
		loading="lazy"
		referrerpolicy="no-referrer"
		style="width:100%;height:50vh"
	>
	</iframe>
</section>
