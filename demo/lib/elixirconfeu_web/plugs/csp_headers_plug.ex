defmodule ElixirConfEUWeb.CSPHeadersPlug do
  @moduledoc """
  A plug to add Content-Security-Policy headers that explicitly allow
  framing from localhost origins.
  """
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    # Register a before_send callback to add CSP headers
    register_before_send(conn, fn conn ->
      origin = get_req_header(conn, "origin") |> List.first()

      # Only modify for localhost/127.0.0.1 origins
      if is_localhost_origin?(origin) do
        # Add CSP header that allows framing from localhost
        put_resp_header(
          conn,
          "content-security-policy",
          "frame-ancestors 'self' http://localhost:* http://127.0.0.1:*;"
        )
      else
        conn
      end
    end)
  end

  # Helper to check if the origin is localhost
  defp is_localhost_origin?(nil), do: false

  defp is_localhost_origin?(origin) do
    String.starts_with?(origin, "http://localhost") ||
      String.starts_with?(origin, "http://127.0.0.1")
  end
end
