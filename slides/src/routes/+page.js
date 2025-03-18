export const ssr = false;

/**
 * @type {import('./$types').PageLoad}
 */
export async function load() {
	const slideFiles = import.meta.glob('$lib/slides/*.{md,svx}');

	const slidePromises = Object.entries(slideFiles)
		.sort(([a], [b]) => a.localeCompare(b))
		.map(async ([path, resolver]) => {
			/** @type {App.MdsvexFile} */
			// @ts-ignore
			const file = await resolver();
			return file;
		});

	const slides = await Promise.all(slidePromises);

	return {
		slides
	};
}
