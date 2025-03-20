defmodule ElixirConfEUWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :elixirconfeu

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_elixirconfeu_key",
    signing_salt: "LXbuaGMD",
    same_site: "Lax"
  ]

  socket "/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options]],
    longpoll: [connect_info: [session: @session_options]]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :elixirconfeu,
    gzip: false,
    only: ElixirConfEUWeb.static_paths()

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :elixirconfeu
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head

  # Custom plug to allow framing from localhost
  plug ElixirConfEUWeb.FrameOptionsPlug

  # Add CSP headers to allow framing
  plug ElixirConfEUWeb.CSPHeadersPlug

  # Add CORS plug to handle cross-origin requests from the slides
  plug CORSPlug,
    origin: [
      "http://localhost:3000",
      "http://localhost:5173",
      "http://127.0.0.1:3000",
      "http://127.0.0.1:5173",
      # Adding all common localhost variations
      "http://localhost:4173",
      "http://127.0.0.1:4173",
      "http://localhost:8080",
      "http://127.0.0.1:8080",
      # Allow all origins in development
      "http://localhost",
      "http://127.0.0.1"
    ],
    headers: [
      "Authorization",
      "Content-Type",
      "Accept",
      "Origin",
      "User-Agent",
      "DNT",
      "Cache-Control",
      "X-Mx-ReqToken",
      "Keep-Alive",
      "X-Requested-With",
      "If-Modified-Since",
      "X-CSRF-Token",
      "X-XSRF-Token"
    ],
    methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    max_age: 86400,
    credentials: true

  plug Plug.Session, @session_options
  plug ElixirConfEUWeb.Router
end
