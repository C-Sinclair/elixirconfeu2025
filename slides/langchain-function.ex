Function.new!(%{
  name: "custom",
  description: "Returns the location of the requested element or item.",
  parameters_schema: %{
    type: "object",
    properties: %{
      thing: %{
        type: "string",
        description: "The thing whose location is being requested."
      }
    },
    required: ["thing"]
  },
  function: fn %{"thing" => thing} = _arguments, context ->
    # our context is a pretend item/location location map
    {:ok, context[thing]}
  end
})
