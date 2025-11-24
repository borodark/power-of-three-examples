# ADBC Database Connection Setup

This document describes the ADBC (Apache Arrow Database Connectivity) configuration for the power-of-three-examples project.

## Configuration Overview

The application now includes ADBC (Apache Arrow Database Connectivity) support for analytical queries via PostgreSQL. The configuration assumes a PostgreSQL database is running on:

- **Host**: localhost
- **Port**: 15432
- **Username**: username
- **Password**: password
- **Database**: test

## Application Architecture

### Child Specs in Application Supervisor

The application supervisor now manages:

1. **Postgres.Repo** - Traditional Ecto ORM for relational queries
2. **Adbc.Database** - ADBC database connection for analytical queries
3. **Adbc.Connection** - ADBC connection handle for executing queries

### Configuration Details

#### Adbc.Database
```elixir
{Adbc.Database,
 [
   driver: :postgresql,
   uri: "postgresql://username:password@localhost:15432/test",
   process_options: [name: ExamplesOfPoT.AdbcDB]
 ]}
```

- **driver**: PostgreSQL driver
- **uri**: Connection string with all credentials embedded
- **process_options**: OTP process naming (registered name: `ExamplesOfPoT.AdbcDB`)

#### Adbc.Connection
```elixir
{Adbc.Connection,
 [
   database: ExamplesOfPoT.AdbcDB,
   process_options: [name: ExamplesOfPoT.AdbcConn]
 ]}
```

- **database**: Reference to the Adbc.Database process
- **process_options**: OTP process naming (registered name: `ExamplesOfPoT.AdbcConn`)

## Setting Up PostgreSQL

### Option 1: Docker Compose (Recommended)

The project includes a `compose.yml` with full stack setup. To start just the PostgreSQL on port 15432:

```bash
# Start PostgreSQL service
docker-compose up -d postgresql

# Verify it's running
docker-compose ps postgresql
```

### Option 2: Local PostgreSQL Installation

If you have PostgreSQL installed locally:

```bash
# Create the test database
createdb -U postgres -p 15432 test

# Or if using default port 5432:
createdb -U postgres test
```

### Option 3: Docker Standalone

```bash
docker run -d \
  --name postgres-adbc \
  -e POSTGRES_USER=username \
  -e POSTGRES_PASSWORD=password \
  -e POSTGRES_DB=test \
  -p 15432:5432 \
  postgres:alpine
```

## Configuring Connection Parameters

To change the ADBC database connection settings, edit `lib/pot_examples/application.ex`:

### Change Host/Port:
```elixir
uri: "postgresql://username:password@YOUR_HOST:YOUR_PORT/test"
```

### Change Credentials:
```elixir
uri: "postgresql://YOUR_USER:YOUR_PASSWORD@localhost:15432/test"
```

### Change Database Name:
```elixir
uri: "postgresql://username:password@localhost:15432/YOUR_DATABASE"
```

## Running the Application

### Development Mode

```bash
# Install dependencies and set up database
mix setup

# Start the Phoenix server
mix phx.server

# Or in interactive mode
iex -S mix phx.server
```

### Testing

```bash
# Run all tests
mix test

# Run with verbose output
mix test --verbose

# Run a specific test file
mix test test/pot_examples_web/controllers/page_controller_test.exs
```

## Accessing ADBC Connection

Once the application is running, you can access the ADBC connection from anywhere in your code:

### Interactive Elixir (iex) Examples

First, ensure PostgreSQL is running on localhost:15432 with a database named `test` (see [Setting Up PostgreSQL](#setting-up-postgresql) section).

Then start the application in interactive mode:

```bash
iex -S mix phx.server
```

The ADBC connection will be automatically established and registered as `ExamplesOfPoT.AdbcConn`. Now in iex, you can:

#### 1. Get the Connection PID

```elixir
# Get the registered ADBC connection process
conn_pid = Process.whereis(ExamplesOfPoT.AdbcConn)

# Verify the connection is active
IO.inspect(conn_pid)
# => #PID<0.123.0>
```

#### 2. Execute a Simple Query

```elixir
# Get the connection
conn = Process.whereis(ExamplesOfPoT.AdbcConn)

# Execute a query
{:ok, results} = Adbc.Connection.query(conn, "SELECT 1 as test_column, 'hello' as message")

# Inspect the results
IO.inspect(results)
```

#### 3. Query with Results from a Table

```elixir
# Assuming you have a 'users' table in your database
conn = Process.whereis(ExamplesOfPoT.AdbcConn)

# Execute a query
case Adbc.Connection.query(conn, "SELECT id, name FROM users LIMIT 10") do
  {:ok, results} ->
    IO.puts("Query succeeded!")
    IO.inspect(results, limit: :infinity)

  {:error, error} ->
    IO.puts("Query failed:")
    IO.inspect(error)
end
```

#### 4. Using Query with Parameters

```elixir
conn = Process.whereis(ExamplesOfPoT.AdbcConn)

# Prepare statement with parameters
case Adbc.Connection.query(
  conn,
  "SELECT * FROM users WHERE id = ?",
  [1]
) do
  {:ok, results} -> IO.inspect(results)
  {:error, error} -> IO.inspect(error)
end
```

#### 5. Execute Query with Bang Version (raises on error)

```elixir
conn = Process.whereis(ExamplesOfPoT.AdbcConn)

# This will raise an error if query fails
results = Adbc.Connection.query!(conn, "SELECT version()")
IO.inspect(results)
```

### Processing Results

ADBC returns results as Apache Arrow tables. To convert to common formats:

```elixir
conn = Process.whereis(ExamplesOfPoT.AdbcConn)

# Execute query
{:ok, table} = Adbc.Connection.query(conn, "SELECT * FROM your_table LIMIT 5")

# Convert to list of maps (requires converting Arrow format)
# Arrow format is the native output, typically used with analytical libraries
IO.inspect(table)
```

### Common ADBC Connection Functions

```elixir
conn = Process.whereis(ExamplesOfPoT.AdbcConn)

# Get connection info
Adbc.Connection.get_info(conn)

# Get available table types
Adbc.Connection.get_table_types(conn)

# Get database objects (tables, schemas, etc)
Adbc.Connection.get_objects(conn)

# Set connection options
Adbc.Connection.set_option(conn, "option_name", "option_value")
```

## Troubleshooting

### Connection Refused Error

**Error**: `tcp connect (localhost:15432): connection refused`

**Solution**:
- Verify PostgreSQL is running on port 15432
- Check credentials: username/password/database
- Use docker-compose or Docker to start PostgreSQL

### Application Won't Start

**Error**: Application exited with startup error related to ADBC

**Solutions**:
1. Check database is accessible: `psql -h localhost -p 15432 -U username -d test`
2. Verify connection credentials in `application.ex`
3. Check PostgreSQL logs for errors

### Connection Timeout

**Error**: Connection hangs during startup

**Solution**:
- Increase timeout in child_spec (add `:timeout` to `process_options`)
- Check network connectivity to database host
- Verify firewall allows port 15432

## Integration with Power of Three

The ADBC connection is used by the Power of Three library for:

- Analytical query execution
- Multi-dimensional aggregations
- Cube operations on Arrow data

The Postgres.Repo (Ecto) continues to handle:

- Traditional CRUD operations
- Relationships and validations
- Transaction management

## Files Modified

- `lib/pot_examples/application.ex` - Added ADBC child specs
- `config/test.exs` - Fixed repository configuration

## Quick Reference for iex

```elixir
# Get connection
conn = Process.whereis(ExamplesOfPoT.AdbcConn)

# Execute query (returns {:ok, results} or {:error, error})
Adbc.Connection.query(conn, "SELECT * FROM your_table LIMIT 10")

# Execute query with pattern matching
case Adbc.Connection.query(conn, "SELECT COUNT(*) as count FROM your_table") do
  {:ok, result} -> IO.inspect(result)
  {:error, error} -> IO.inspect(error)
end

# Get database metadata
Adbc.Connection.get_info(conn)

# Get available tables
Adbc.Connection.get_objects(conn)

# Parameterized query
Adbc.Connection.query(conn, "SELECT * FROM users WHERE id = ?", [1])
```

## References

- [ADBC Documentation](https://arrow.apache.org/adbc/)
- [Power of Three Documentation](https://github.com/borodark/power_of_three)
- [Phoenix Documentation](https://www.phoenixframework.org/)
