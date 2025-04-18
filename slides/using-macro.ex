defmacro __using__(_opts) do
  Module.register_attribute(__CALLER__.module, :params, accumulate: true, persist: true)

  quote do
    # magic function which is looked for by the LLM to determine if a module is LLM enabled
    def __magic_is_real__ do
      true
    end
  end
end
