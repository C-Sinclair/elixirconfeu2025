<script>
	let { children } = $props();
</script>

<h1 data-id="slide-title">
	{@render children()}
</h1>

<style>
	h1 {
		display: flex;
		align-items: center;
		justify-content: center;
		gap: 1rem;
	}
</style>
