defmodule ElixirConfEU.Repo do
  use Ecto.Repo,
    otp_app: :elixirconfeu,
    adapter: Ecto.Adapters.SQLite3
end
