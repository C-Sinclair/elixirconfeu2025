def get_functions do
  # ensure_modules_loaded
  Application.spec(:elixirconfeu, :modules)
  |> Enum.each(&Code.ensure_loaded/1)

  :code.all_loaded()
  |> Enum.filter(fn {module, _} ->
    Kernel.function_exported?(module, :__magic_is_real__, 0)
  end)
  |> Enum.map(fn {module, _path} -> module end)
  |> Enum.map(&module_functions/1)
  |> List.flatten()
end
