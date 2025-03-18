// See https://svelte.dev/docs/kit/types#app.d.ts
// for information about these interfaces
declare global {
	namespace App {
		// interface Error {}
		// interface Locals {}
		// interface PageData {}
		// interface PageState {}
		// interface Platform {}

		interface MdsvexFile {
			default: import('svelte/internal').SvelteComponent<any, any, any>;
			metadata: Record<string, string>;
		}
	}
}

export {};
