# Cube ADBC Connection Pool Setup

This document describes the Cube ADBC connection pool setup for the Power of Three Examples application.

## Overview

The application now includes a connection pool for querying Cube.js via the Arrow Native protocol using ADBC (Arrow Database Connectivity). This provides high-performance, type-safe access to Cube's semantic layer.

## Architecture

```
┌─────────────────────────────────────────────┐
│  ExamplesOfPoT.Application                  │
│  (Supervision Tree)                         │
│                                             │
│  ┌────────────────────────────────────┐    │
│  │  PowerOfThree.CubeConnectionPool   │    │
│  │  (poolboy supervisor)               │    │
│  │                                    │    │
│  │  ┌──────────────────────────────┐ │    │
│  │  │  Pool workers (N)            │ │    │
│  │  │  (ADBC connections)          │ │    │
│  │  └──────────────────────────────┘ │    │
│  └────────────────────────────────────┘    │
└─────────────────────────────────────────────┘
         │
         ▼ (Arrow Native Protocol, TCP)
┌─────────────────────────────────────────────┐
│  cubesqld (Rust Proxy)                      │
│  Port 8120                                  │
└─────────────────────────────────────────────┘
         │
         ▼ (HTTP/REST)
┌─────────────────────────────────────────────┐
│  Cube.js API Server                         │
│  Port 4008                                  │
└─────────────────────────────────────────────┘
```

## Components

### 1. PowerOfThree.CubeConnectionPool (poolboy)

Manages the connection pool with:
- **Pool workers**: One ADBC connection per worker
- **Configurable size**: `size` and `max_overflow`
- **poolboy scheduling**: FIFO by default

**Module**: `deps/power_of_3/lib/power_of_three/cube_connection_pool.ex`

### 2. ExamplesOfPoT.CubeQuery (Helper Module)

Provides convenient query functions:
- Simple queries: `CubeQuery.query/1`, `CubeQuery.query!/1`
- Materialized results: `CubeQuery.to_map/1`
- Cube-specific queries: `CubeQuery.query_cube/1`
- Metadata queries: `CubeQuery.list_cubes/0`, `CubeQuery.describe_cube/1`

**Module**: `lib/pot_examples/cube_query.ex`

## Configuration

### config/config.exs

```elixir
config :power_of_3, PowerOfThree.CubeConnectionPool,
  size: System.schedulers_online() * 2,
  max_overflow: 2,
  host: "localhost",
  port: 8120,
  token: "test",
  driver: :cube,
  driver_version: "0.1.2"
```

### Options

- **size**: Number of pooled workers (default: 5)
- **max_overflow**: Extra workers allowed under load
- **host**: Cube server hostname (default: "localhost")
- **port**: Arrow Native protocol port (default: 8120)
- **token**: Cube API authentication token
- **driver**: Driver atom or path (default: `:cube`)
- **driver_version**: Driver version when using atom driver

## Usage Examples

### Basic Query

```elixir
# Using the pool helper
{:ok, result} = ExamplesOfPoT.CubeQuery.query("SELECT 1 as test")

# Or directly
{:ok, result} = PowerOfThree.CubeConnectionPool.query("SELECT 1 as test")
```

### Materialized Query

```elixir
# Get data as map
data = ExamplesOfPoT.CubeQuery.query!("SELECT 1 as a, 2 as b")
|> ExamplesOfPoT.CubeQuery.to_map()

# Result: %{"a" => [1], "b" => [2]}
```

### Cube-Specific Query

```elixir
# Query with dimensions and measures
{:ok, data} = ExamplesOfPoT.CubeQuery.query_cube(
  cube: "of_customers",
  dimensions: ["brand", "city"],
  measures: ["count"],
  order_by: "2 DESC",
  limit: 10
)

# Result:
# %{
#   "brand" => ["Nike", "Adidas", ...],
#   "city" => ["New York", "London", ...],
#   "measure(of_customers.count)" => [1500, 1200, ...]
# }
```

### Get Specific Connection

```elixir
# Check out a connection from the pool
{worker, conn} = PowerOfThree.CubeConnectionPool.checkout()

# Use it directly
{:ok, result} = Adbc.Connection.query(conn, "SELECT 1")

# Return it to the pool
PowerOfThree.CubeConnectionPool.checkin(worker)
```

### Concurrent Queries

```elixir
# The pool automatically distributes queries across connections
tasks = for i <- 1..100 do
  Task.async(fn ->
    ExamplesOfPoT.CubeQuery.query!("SELECT #{i} as num")
    |> ExamplesOfPoT.CubeQuery.to_map()
  end)
end

results = Task.await_many(tasks)
```

## Prerequisites

### 1. Build the Cube Driver

```bash
cd path/to/adbc_driver_cube
make
```

This creates `priv/lib/libadbc_driver_cube.so`.

### 2. Start Cube Services

**Terminal 1: Start Cube.js API**
```bash
cd path/to/cube/examples/recipes/arrow-ipc
./start-cube-api.sh
```

Wait for: `🚀 Cube API server is listening on 4008`

**Terminal 2: Start cubesqld**
```bash
cd path/to/cube/examples/recipes/arrow-ipc
./start-cubesqld.sh
```

Wait for:
```
🔗 Cube SQL (arrow) is listening on 0.0.0.0:8120
```

**Note**: cubesqld also listens on port 4444 (PostgreSQL wire protocol) for legacy compatibility, but we only use the Arrow Native protocol (port 8120).

### 3. Start the Application

```bash
cd path/to/power-of-three-examples
mix phx.server
```

## Testing

### Run Pool Tests

```bash
# Run all Cube ADBC tests
mix test test/adbc_cube_basic_test.exs --include cube

# Run specific test
mix test test/adbc_cube_basic_test.exs:25 --include cube
```

### Manual Testing in IEx

```elixir
# Start application
iex -S mix

# Check pool size
PowerOfThree.CubeConnectionPool.status()
# => {:ready, size, overflow, busy, waiting}

# Run simple query
ExamplesOfPoT.CubeQuery.query!("SELECT 1 as test")
|> ExamplesOfPoT.CubeQuery.to_map()
# => %{"test" => [1]}

# List available cubes
{:ok, cubes} = ExamplesOfPoT.CubeQuery.list_cubes()
# => {:ok, ["of_customers", ...]}

# Query a cube
data = ExamplesOfPoT.CubeQuery.query_cube!(
  cube: "of_customers",
  dimensions: ["brand"],
  measures: ["count"],
  limit: 5
)
# => %{"brand" => [...], "measure(of_customers.count)" => [...]}
```

## Monitoring

### Check Pool Health

```elixir
# Get pool status
PowerOfThree.CubeConnectionPool.status()

# Check if connections are alive
{worker, conn} = PowerOfThree.CubeConnectionPool.checkout()
{Process.alive?(worker), Process.alive?(conn)}
PowerOfThree.CubeConnectionPool.checkin(worker)
```

### Connection Distribution

```elixir
# Test round-robin distribution
connections =
  for _ <- 1..5 do
    {worker, conn} = PowerOfThree.CubeConnectionPool.checkout()
    PowerOfThree.CubeConnectionPool.checkin(worker)
    conn
  end

connections |> Enum.uniq() |> length()
```

## Troubleshooting

### Connection Refused

**Error**: `{:error, :econnrefused}`

**Solution**: Start cubesqld
```bash
cd path/to/cube/examples/recipes/arrow-ipc
./start-cubesqld.sh
```

### Driver Not Found

**Error**: `Cube driver not found at priv/lib/libadbc_driver_cube.so`

**Solution**: Build the driver
```bash
cd path/to/adbc_driver_cube
make
```

Then ensure the library is in the project's priv/lib:
```bash
ls -la path/to/power-of-three-examples/priv/lib/libadbc_driver_cube.so
```

### Pool Not Starting

**Check**: Verify configuration
```elixir
Application.get_env(:power_of_3, PowerOfThree.CubeConnectionPool)
```

**Check**: Look at supervisor children
```elixir
Supervisor.which_children(PowerOfThree.CubeConnectionPool)
```

### Query Failures

**Enable Debug Logging**: The C driver outputs extensive debug information to stderr. Check your terminal for:
```
[NativeClient::ExecuteQuery] Skipping schema-only message
[CubeArrowReader::Init] Starting with buffer size: 304
[ParseSchemaFlatBuffer] Field 0: name='test', type=10
```

## Performance Considerations

### Pool Sizing

Default pool size is `System.schedulers_online() * 2`:
- **8-core CPU**: 16 connections
- **16-core CPU**: 32 connections

Adjust based on:
- Query concurrency needs
- Memory constraints
- cubesqld connection limits

### Query Patterns

**Efficient**:
```elixir
# Single query with filters
ExamplesOfPoT.CubeQuery.query_cube(
  cube: "of_customers",
  dimensions: ["brand"],
  measures: ["count"],
  where: "brand = 'Nike'",
  limit: 10
)
```

**Less Efficient**:
```elixir
# Multiple queries to filter
all_data = ExamplesOfPoT.CubeQuery.query_cube!(
  cube: "of_customers",
  dimensions: ["brand"],
  measures: ["count"]
)

# Filter in Elixir
nike_data = Enum.filter(all_data["brand"], &(&1 == "Nike"))
```

### Caching

Consider caching frequently-queried data:
```elixir
defmodule CachedCubeQuery do
  use GenServer

  # Cache query results for 5 minutes
  @cache_ttl 5 * 60 * 1000

  def query_cached(sql) do
    # Check cache, query if miss
    # ...
  end
end
```

## Advanced Usage

### Custom Pool Configuration per Environment

```elixir
# config/dev.exs
config :power_of_3, PowerOfThree.CubeConnectionPool,
  size: 4,  # Smaller pool for dev
  host: "localhost",
  port: 8120,
  token: "dev-token"

# config/prod.exs
config :power_of_3, PowerOfThree.CubeConnectionPool,
  size: 32,  # Larger pool for prod
  host: System.get_env("CUBE_HOST"),
  port: String.to_integer(System.get_env("CUBE_PORT")),
  token: System.get_env("CUBE_TOKEN")
```

### Multiple Cube Environments

```elixir
# Start multiple pools for different Cube instances
# (requires separate pool modules or extending the pool to accept custom names)
```

## Related Documentation

- **ADBC Cube Driver**: `path/to/adbc_driver_cube/README.md`
- **Architecture**: `path/to/adbc/ARCHITECTURE.md`
- **Iteration Manual**: `path/to/adbc/ITERATION_MANUAL.md`
- **Testing**: `path/to/adbc/CUBE_TESTING_STATUS.md`

## Status

✅ **Cube pool is configured and ready to use**

Components:
- [x] Connection pool supervisor
- [x] Round-robin distribution
- [x] Helper query module
- [x] Test suite
- [x] Documentation

Next Steps:
- [ ] Add connection pooling metrics
- [ ] Implement query result caching
- [ ] Add Phoenix LiveView integration examples
- [ ] Create data visualization components
