<script>
	import MeCard from '$lib/components/MeCard.svelte';
	import SlideTitle from '$lib/components/SlideTitle.svelte';
</script>

<section data-auto-animate>
	<header>
		<SlideTitle>Meta-Programming in Elixir</SlideTitle>
		<h2>Dynamic Function Calling with LLMs</h2>
	</header>

	<p>May 2025</p>

	<footer>
		<MeCard />
	</footer>
</section>

<style>
	header {
		margin-top: 20vh;
	}

	footer {
		flex: 1;
		display: flex;
		justify-content: center;
		position: fixed;
		width: 100%;
		top: 50vh;
	}
</style>
