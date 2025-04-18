def module_functions(module) do
  {:docs_v1, _, _, _, _, _, function_docs} = Code.fetch_docs(module)

  # ... a bunch of unwrapping of the data 

  LangChain.Function.new!(%{
    name: name,
    description: description,
    params: params,
    function: fn arguments, context ->
      # Call the module function itself
      apply(module, function, [arguments, context])
    end
  })
end
