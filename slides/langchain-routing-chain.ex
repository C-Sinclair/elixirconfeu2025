routes = [
  PromptRoute.new!(%{
    name: "marketing_email",
    description: "Create a marketing focused email",
    chain: marketing_email_chain
  }),
  PromptRoute.new!(%{
    name: "blog_post",
    description: "Create a blog post that will be linked from the company's landing page",
    chain: blog_post_chain
  })
]

selected_route =
  RoutingChain.new!(%{
    llm: ChatOpenAI.new!(%{model: "gpt-40-mini", stream: false}),
    input_text: "Let's create a marketing blog post about our new product 'Fuzzy Furies'",
    routes: routes,
    default_route: PromptRoute.new!(%{name: "DEFAULT", chain: fallback_chain})
  })
  |> RoutingChain.evaluate()
