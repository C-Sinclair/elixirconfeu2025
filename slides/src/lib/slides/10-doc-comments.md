# Doc Comments 

`@doc` is just another module attribute. Which means it exists at compile time, and we can therefore access it at runtime! 

```elixir [14|1|3|4|5|7-13]
{:docs_v1, 
 _,
 :elixir, 
 "text/markdown", 
 %{"en" => @moduledoc}, 
 _, 
 [{
    {:function, :foo, _arity}, 
    _, 
    _, 
    %{"en" => @doc}, 
    _
  }]
} = Code.fetch_docs(module)
```

