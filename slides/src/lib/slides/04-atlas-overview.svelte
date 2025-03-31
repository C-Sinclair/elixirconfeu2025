<script>
	import SlideTitle from '$lib/components/SlideTitle.svelte';
	import Notes from '$lib/deck/notes.svelte';
</script>

<section data-auto-animate>
	<SlideTitle
		>Multiverse Atlas

		<div>
			<svg
				width="24"
				height="24"
				viewBox="0 0 24 24"
				fill="none"
				xmlns="http://www.w3.org/2000/svg"
				stroke-width="0"
				class="stroke-current text-brand-800 h-4 w-4 cursor-default [--background:var(--color-brand-100)] mb-2 scale-[2]"
				><path
					data-part="background"
					d="M0 12C0 5.37258 5.37258 0 12 0C18.6274 0 24 5.37258 24 12C24 18.6274 18.6274 24 12 24C5.37258 24 0 18.6274 0 12Z"
					fill="var(--background, var(--color-brand-50))"
				></path><path
					data-part="eye-left"
					d="M9.9489 6.84308L7 12H7.5H7.75H8L10.25 8L10.401 7.75V12H11.25V9V6H10.401C10.3331 6.12793 10.1656 6.4413 9.9489 6.84308Z"
					fill="currentColor"
				></path><path
					data-part="eye-right"
					d="M15.9489 6.84308L13 12H13.5H13.75H14L16.25 8L16.401 7.75V12H17.25V9V6H16.401C16.3331 6.12793 16.1656 6.4413 15.9489 6.84308Z"
					fill="currentColor"
				></path><path
					data-part="mouth"
					fill-rule="evenodd"
					clip-rule="evenodd"
					d="M8.5 16.5C12.5424 18.0252 15.6733 15.1798 16.5 13.75L16.875 14.0516L17.25 14.3533C16.1941 16.1796 12.9527 19.2399 8.25 17.4656L8.5 16.5Z"
					fill="currentColor"
					class="mouth"
				></path></svg
			>
		</div>
	</SlideTitle>

	<img src="/img/atlas-side-panels.png" alt="Atlas Overview" />

	<Notes>
		Relevant to this talk, I work on Atlas. An embedded AI powered coach and learning tutor for
		Multiverse learners.
	</Notes>
</section>

<style>
	div {
		border-radius: 8rem;
		width: 5rem;
		height: 5rem;
		display: flex;
		align-items: center;
		justify-content: center;
		background-color: #e7eafe;
	}
	svg {
		width: 8rem;
		height: 8rem;
	}
	.text-brand-800 {
		color: #273182;
	}
	img {
		max-height: 40vh;
	}
</style>
