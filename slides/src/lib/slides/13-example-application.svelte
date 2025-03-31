<script>
	import SlideTitle from '$lib/components/SlideTitle.svelte';
	import { slide } from 'svelte/transition';
</script>

<section data-auto-animate>
	<SlideTitle>Demo time</SlideTitle>

	<iframe
		transition:slide={{ duration: 2000 }}
		src="http://localhost:4000/iframe"
		title="Demo"
		sandbox="allow-same-origin allow-scripts allow-forms allow-popups allow-popups-to-escape-sandbox allow-modals allow-top-navigation"
		loading="lazy"
		referrerpolicy="no-referrer"
		style="width:100%;height:50vh"
	>
	</iframe>
</section>
