# Module Attributes

`@tag` in ExUnit is just a plain old module attribute 

```elixir
@tag :my_tag
test "a test which does a thing" do
    ...
end
```

---

# Module Attributes

`@tag` in ExUnit is just a plain old module attribute 

```elixir
@tag :my_tag
test "a test which does a thing" do
    ...
end
```

Hottip 🔥 


```bash
mix test --only my_tag
```

