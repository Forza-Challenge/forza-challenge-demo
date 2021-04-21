defmodule FCDemo.Repo do
  use Ecto.Repo,
    otp_app: :forza_challenge_demo,
    adapter: Ecto.Adapters.Postgres
end
