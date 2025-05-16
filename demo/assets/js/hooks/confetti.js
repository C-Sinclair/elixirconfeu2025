export default {
  mounted() {
    this.handleEvent("confetti", ({ particleCount, spread }) => {
      if (typeof confetti === "function") {
        confetti({ particleCount, spread });
      } else {
        console.warn("confetti function is not available");
      }
    });
  },
};
