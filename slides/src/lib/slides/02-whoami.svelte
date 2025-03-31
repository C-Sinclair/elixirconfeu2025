<script>
	import MeCard from '$lib/components/MeCard.svelte';
	import SlideTitle from '$lib/components/SlideTitle.svelte';

	const items = [
		'No CompSci background',
		'Self taught Javascript canvas ninja',
		'PHP agency work 💜 jQuery',
		'React embedded in C++ desktop application',
		'Next.JS (~ v12)',
		'Elixir, Liveview, React at an EdTech unicorn'
	];
</script>

<section data-auto-animate>
	<SlideTitle>Whoami</SlideTitle>

	<MeCard />
</section>

{#each items as _, index}
	<section data-auto-animate>
		<SlideTitle>Whoami</SlideTitle>

		<MeCard />

		<p>history</p>

		<ul data-id="history-list">
			{#each items.slice(0, index + 1) as item}
				<li>{item}</li>
			{/each}
		</ul>
	</section>
{/each}

<style>
	ul {
		width: 100vw;
		height: 20vh;
	}
</style>
