defmodule ElixirConfEUWeb.FrameOptionsPlug do
  @moduledoc """
  A plug to customize the X-Frame-Options header based on request origin.
  Allows embedding in iframes from localhost origins.
  """
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    # Register a before_send callback to modify headers just before the response is sent
    register_before_send(conn, fn conn ->
      origin = get_req_header(conn, "origin") |> List.first()

      # Allow framing from localhost
      cond do
        is_nil(origin) ->
          # No origin header, keep default behavior
          conn

        String.starts_with?(origin, "http://localhost") ||
            String.starts_with?(origin, "http://127.0.0.1") ->
          # Force remove the restrictive header and set a new one that allows
          conn
          |> delete_resp_header("x-frame-options")

        # Completely remove the header instead of setting ALLOW-FROM
        # since ALLOW-FROM is deprecated and not supported in Chrome/Safari

        true ->
          # For other origins, keep default behavior
          conn
      end
    end)
  end
end
