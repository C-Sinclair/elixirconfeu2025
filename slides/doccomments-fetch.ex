{
  :docs_v1,
  _,
  :elixir,
  "text/markdown",
  %{"en" => @moduledoc},
  _,
  [
    {
      {:function, :foo, _arity},
      _,
      _,
      %{"en" => @doc},
      _
    }
  ]
} = Code.fetch_docs(module)
