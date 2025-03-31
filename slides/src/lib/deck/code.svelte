<script>
	let { id = null, lines = null, noescape = false, children } = $props();
</script>

<pre data-id={id || null}>
	<code
		data-trim
		data-line-numbers={lines || null}
		data-noescape={noescape || null}
		class="hljs language-elixir">
		{@render children()}
	</code>
</pre>
