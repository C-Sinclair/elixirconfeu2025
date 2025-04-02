<script lang="ts">
	import SlideTitle from '$lib/components/SlideTitle.svelte';

	import { slideOnVisible } from '$lib/actions/slideOnVisible';
</script>

<section data-auto-animate>
	<SlideTitle>Demo time</SlideTitle>

	<!-- <iframe
		use:slideOnVisible
		src="http://localhost:4000/iframe/chat"
		title="Demo"
		sandbox="allow-same-origin allow-scripts allow-forms"
		loading="lazy"
		referrerpolicy="no-referrer"
		style="width:100%;height:50vh"
	>
	</iframe> -->
</section>

<!-- TODO: The function call should maybe show the Elixir code which ran? -->
