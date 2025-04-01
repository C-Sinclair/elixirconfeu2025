<article data-id="me-card">
	<div class="me-card">
		<img src="/me.jpeg" alt="Me" class="avatar" data-id="me-avatar" />
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
		margin: 0;
		line-height: 1;
	}

	.me-card {
		display: grid;
		grid-template-columns: auto 1fr;
		gap: 1rem;
	}

	.me-card > div {
		display: flex;
		flex-direction: column;
		gap: 0.3em;
	}

	.me-card > div {
		align-self: center;
	}

	.name {
		font-size: var(--font-size-4);
		font-weight: 600;
	}

	p:has(.title, .company) {
		font-size: var(--font-size-1);
		font-weight: 400;
	}

	footer {
		display: flex;
		gap: 2rem;
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
		margin: 0;
	}
</style>
