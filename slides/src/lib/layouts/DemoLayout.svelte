<script>
	import { onMount } from 'svelte';
</script>

<div class="demo-layout">
	<slot />

	<div class="iframe-container">
		<iframe
			src="http://localhost:4000/iframe"
			title="Demo"
			sandbox="allow-same-origin allow-scripts allow-forms allow-popups allow-popups-to-escape-sandbox allow-modals allow-top-navigation"
			loading="lazy"
			referrerpolicy="no-referrer"
		>
		</iframe>
	</div>
</div>

<style>
	.demo-layout {
		display: flex;
		flex-direction: column;
		height: 100%;
	}

	.iframe-container {
		position: relative;
		flex: 1;
		min-height: 300px;
	}

	iframe {
		width: 100%;
		height: 100%;
		border: 1px solid #ccc;
		border-radius: 4px;
	}
</style>
