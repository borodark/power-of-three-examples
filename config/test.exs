import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :pot_examples, Postgres.Repo,
  port: 7432,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "pot_examples_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

config :pot_examples, Cubes.Repo,
  port: 15432,
  stacktrace: true,
  username: "username",
  password: "password",
  hostname: "localhost",
  database: "test",
  ownership_timeout: 300_000,
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10


# We don't run a server during test. If one is required,
# you can enable the server option below.
config :pot_examples, ExamplesOfPoTWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "j/pEPiQDQGCrKIa6oZTl0XuIFpB8d29yxr/n7z86O/eHlNWS9s6MDJ6KWHqnSB6L",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true
