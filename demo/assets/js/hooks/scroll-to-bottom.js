const ScrollToBottom = {
  async mounted() {
    this.el.scrollIntoView({ behavior: "smooth", block: "end" });
  },
};

export default ScrollToBottom;
