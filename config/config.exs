# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :pot_examples,
  namespace: ExamplesOfPoT,
  ecto_repos: [Postgres.Repo],
  generators: [timestamp_type: :utc_datetime]

config :pot_examples, Postgres.Repo,
  port: 7432,
  stacktrace: true,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "pot_examples_dev",
  ownership_timeout: 300_000,
  timeout: 6_000_000,
  #  disable_composite_types: true,
  pool_size: System.schedulers_online() * 2


# Cube ADBC connection pool configuration
config :pot_examples, Adbc.CubePool,
  pool_size: 44,
  host: "localhost",
  port: 8120,
  token: "test",
  username: "username",
  password: "password"

# Configures the endpoint
config :pot_examples, ExamplesOfPoTWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: ExamplesOfPoTWeb.ErrorHTML, json: ExamplesOfPoTWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: ExamplesOfPoT.PubSub,
  live_view: [signing_salt: "izstBB3n"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  pot_examples: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  pot_examples: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
