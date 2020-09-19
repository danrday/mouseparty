defmodule Mouseparty.Repo do
  use Ecto.Repo,
    otp_app: :mouseparty,
    adapter: Ecto.Adapters.Postgres
end
