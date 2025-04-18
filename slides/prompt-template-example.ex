prompt =
  PromptTemplate.from_template!("Suggest a good name for a company that makes <%= @product %>?")

PromptTemplate.format(prompt, %{product: "colorful socks"})
# => "Suggest a good name for a company that makes colorful socks?
