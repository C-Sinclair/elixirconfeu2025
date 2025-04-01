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
	<SlideTitle>Whoami <img src="/me.jpeg" alt="Me" class="avatar" data-id="me-avatar" /></SlideTitle>
</section>

{#each items as _, index}
	<section data-auto-animate>
		<SlideTitle
			>Whoami <img src="/me.jpeg" alt="Me" class="avatar" data-id="me-avatar" /></SlideTitle
		>
		<div class="terminal">
			<header>
				<div class="close-button"></div>
				<div class="minimize-button"></div>
				<div class="maximize-button"></div>
			</header>

			<p>history</p>

			<ul data-id="history-list">
				{#each items.slice(0, index + 1) as item}
					<li>{item}</li>
				{/each}
			</ul>
		</div>
	</section>
{/each}

<style>
	ul {
		width: 100vw;
		height: 20vh;
	}

	.terminal {
		display: flex;
		flex-direction: column;
		border-radius: 1em;
		height: 70vh;
		width: 70vw;
	}

	header {
		display: flex;
		align-items: flex-start;
		justify-content: flex-start;
		width: 100%;
		padding: 0.5rem;
	}
</style>
