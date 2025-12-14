# Cube tests require cubesqld to be running on port 4445
# Run with: mix test --include cube
# Or use: mix test test/cube_pool_test.exs --include cube
ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Postgres.Repo, :manual)
