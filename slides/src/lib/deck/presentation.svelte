<script>
	import Code from './code.svelte';
	import Notes from './notes.svelte';

	// import all markdown files from slides directory
	const slides = import.meta.glob('$lib/slides/*.md');

	// order by file name
	const slideKeys = Object.keys(slides).sort((a, b) => a.localeCompare(b));
</script>

<section data-auto-animate>
	<ul id="ullist">
		<li>React</li>
		<li>Solid</li>
		<li>Svelte</li>
		<li>Vue</li>
	</ul>
</section>

<section data-auto-animate>
	<ul id="ullist">
		<li>Svelte ❤️</li>
		<li>React</li>
		<li>Solid</li>
		<li>Vue</li>
	</ul>
	<Notes>
		<p>This is important</p>
	</Notes>
</section>

<section data-auto-animate>
	<Code id="code" lines>
		{`
			function love() {}
	 `}
	</Code>
</section>

<section data-auto-animate>
	<Code id="code" lines="2|1-3">
		{`
			function love() {
				console.log('Svelte')
			}
	 `}
	</Code>
</section>

{#each slideKeys as slideKey}
	<section data-auto-animate data-markdown={slideKey}></section>
{/each}
