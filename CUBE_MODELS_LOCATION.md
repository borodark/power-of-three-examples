# Cube Models Location

**Date:** 2025-12-26

## Current Location

Cube models have been moved to the live Cube API server location for integration with Arrow IPC testing:

**Location:** `~/projects/learn_erl/cube/examples/recipes/arrow-ipc/model/cubes/`

## Cube Models

The following cube models are now served by the live Cube API:

1. **mandata_captate.yaml** - Auto-generated from zhuzha (public.order table)
2. **of_addresses.yaml** - Generated from address table
3. **of_customers.yaml** - Customers cube
4. **orders.yaml** - Auto-generated orders cube
5. **power_customers.yaml** - Customers cube

## Accessing the Cubes

### Via Arrow Native Protocol (Port 4445)

The cubes are accessible via ADBC with the Cube driver:

```bash
# Connection settings
Host: localhost
Port: 4445
Mode: native
Token: test
```

### Via HTTP API (Port 4008)

```bash
curl http://localhost:4008/cubejs-api/v1/meta -H "Authorization: test"
```

### Via ADBC (Elixir)

```elixir
{:ok, db} = Adbc.Database.start_link(
  driver: "/path/to/libadbc_driver_cube.so",
  "adbc.cube.host": "localhost",
  "adbc.cube.port": "4445",
  "adbc.cube.connection_mode": "native",
  "adbc.cube.token": "test"
)
```

## Live Reloading

The Cube API server watches the `model/cubes/` directory and automatically reloads when files are modified. No manual restart needed.

## Testing

ADBC integration tests can now access power-of-three cubes:

```bash
cd ~/projects/learn_erl/adbc
mix test test/adbc_cube_basic_test.exs --include cube
```

## Note on Python Tests

- **`test_arrow_cache_performance.py`** - Uses Arrow Native protocol (port 4445)

For Arrow Native examples, see `~/projects/learn_erl/cube/examples/recipes/arrow-ipc/POWER_OF_THREE_QUERY_EXAMPLES.md`.

## Documentation

See `~/projects/learn_erl/cube/examples/recipes/arrow-ipc/POWER_OF_THREE_INTEGRATION.md` for complete integration details.
