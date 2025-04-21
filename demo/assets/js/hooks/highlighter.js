import { codeToHtml } from "shiki";

const Highlight = {
  async mounted() {
    this.el.innerHTML = await codeToHtml(this.el.dataset.source, {
      lang: "elixir",
      theme: "catppuccin-mocha",
    });
  },
};

export default Highlight;
