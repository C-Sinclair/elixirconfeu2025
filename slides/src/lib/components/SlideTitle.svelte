<script>
	let { children, centred = false } = $props();
</script>

<h1 data-id="slide-title" class:centred>
	{@render children()}
</h1>

<style>
	h1 {
		display: flex;
		align-items: center;
		justify-content: center;
		gap: 1rem;
		margin-bottom: 0.2rem;
	}

	.centred {
		height: 55vh;
	}
</style>
