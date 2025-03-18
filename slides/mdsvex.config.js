import { join } from 'path';

const defaultLayout = join(__dirname, 'src/lib/layouts/DefaultLayout.svelte');
const demoLayout = join(__dirname, 'src/lib/layouts/DemoLayout.svelte');

export default {
	extensions: ['.svx', '.md'],
	smartypants: {
		dashes: 'oldschool'
	},
	remarkPlugins: [],
	rehypePlugins: [],
	layout: {
		_: defaultLayout,
		demo: demoLayout
	}
};
