import Config

if config_env() == :prod do
  # For example: ecto://USER:PASS@HOST/DATABASE
  database_url = System.fetch_env!("DATABASE_URL")

  config :forza_challenge_demo, FCDemo.Repo,
    # ssl: true,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

  # You can generate one by calling: mix phx.gen.secret
  secret_key_base = System.fetch_env!("SECRET_KEY_BASE")

  config :forza_challenge_demo, FCDemoWeb.Endpoint,
    http: [
      port: String.to_integer(System.get_env("PORT") || "8080"),
      transport_options: [socket_opts: [:inet6]],
      compress: true
    ],
    secret_key_base: secret_key_base
end
