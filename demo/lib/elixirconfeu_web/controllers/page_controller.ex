defmodule ElixirConfEUWeb.PageController do
  use ElixirConfEUWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  # Special version for iframe with headers removed
  def iframe(conn, _params) do
    conn
    |> put_resp_header("x-frame-options", "ALLOWALL")
    |> delete_resp_header("content-security-policy")
    |> render(:home, layout: false)
  end
end
