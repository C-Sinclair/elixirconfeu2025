import Unless
macro_unless true do
  IO.puts("this should never be printed"))
end
# => nil
