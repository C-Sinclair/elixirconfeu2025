const ChatHooks = {
  Chat: {
    mounted() {
      this.handleEvents = this.handleEvents.bind(this);
      this.el.addEventListener("phx:simulate_llm_response", this.handleEvents);
    },

    destroyed() {
      this.el.removeEventListener(
        "phx:simulate_llm_response",
        this.handleEvents
      );
    },

    handleEvents(event) {
      // In a real application, we would handle receiving the response from the server
      // For demo purposes, we'll simulate a response after a short delay
      setTimeout(() => {
        this.pushEvent("simulate_llm_response", {
          message_id: event.detail.message_id,
        });
      }, 1500);
    },
  },
};

export default ChatHooks;
