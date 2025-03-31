<script>
</script>

<article data-id="me-card">
	<div class="me-card">
		<img src="/me.jpeg" alt="Me" class="avatar" />
		<div>
			<p class="name">Conor Sinclair</p>
			<p>
				<span class="title">Senior Software Engineer</span> @
				<span class="company">Multiverse</span>
			</p>
			<footer>
				<a href="https://github.com/C-Sinclair" target="_blank" rel="noopener noreferrer">
					<img src="/img/github.svg" alt="GitHub" />
					csinclair
				</a>
				<a href="https://x.com/_csinclair_" target="_blank" rel="noopener noreferrer">
					<img src="/img/x.svg" alt="X icon" />
					@_csinclair_
				</a>
			</footer>
		</div>
	</div>
</article>

<style>
	article {
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
	}

	p {
		text-align: left;
		padding: 0;
		margin: 0.25em 0;
		grid-column: 2;
	}

	.me-card {
		display: grid;
		grid-template-columns: auto 1fr;
		gap: 1rem;
	}

	.avatar {
		height: 8rem;
		width: 8rem;
		max-width: 8rem;
		max-height: 8rem;
		border-radius: 9999px;
	}

	.me-card > div {
		align-self: center;
	}

	.name {
		font-size: var(--font-size-5);
		font-weight: 600;
	}

	:is(.title, .company) {
		font-size: var(--font-size-4);
		font-weight: 400;
	}

	footer {
		display: flex;
		justify-content: space-around;
		width: 100%;
		font-size: var(--font-size-0);
	}

	footer a {
		display: flex;
		align-items: center;
		gap: 0.5rem;
	}

	footer a img {
		width: 1rem;
		height: 1rem;
	}
</style>
