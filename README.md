# Examples Of PoT

Please see https://github.com/borodark/power_of_three/blob/master/README.md


To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Project Documentation

### Cube ADBC Integration

  * **[Cube Pool Setup](CUBE_POOL_SETUP.md)** - Connection pool configuration and usage
  * **[Saturation Testing](SATURATION_TESTING.md)** - Load testing guide for cubesqld (100/1K/10K concurrent queries)
  * **[Database Backup](DATABASE_BACKUP.md)** - Backup and restore procedures with smallest storage size

### Quick Scripts

```bash
# Backup database (smallest size)
./scripts/backup_db.sh

# Restore latest backup
./scripts/restore_db.sh

# Restore specific backup
./scripts/restore_db.sh backups/pot_examples_dev_20251212_015911.dump
```

### Testing

```bash
# Run all tests
mix test

# Run Cube pool tests
mix test test/cube_pool_test.exs --include cube

# Run saturation tests (100 concurrent queries)
mix test test/cube_saturation_test.exs:95 --include cube

# Run all saturation tests (100/1K/10K)
mix test test/cube_saturation_test.exs --include saturation
```

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
