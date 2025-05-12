defmodule MyApp.ModuleAttributes do
  Module.register_attribute(__MODULE__, :value, accumulate: true)
  @value 1
  @value 2
  @value 3
  # [3, 2, 1]
  def val, do: @value
end

