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

The ADBC connection will be automatically established and registered as `ExamplesOfPoT.AdbcConn`.

#### Getting the Connection

```elixir
# Get the registered ADBC connection process
conn = Process.whereis(ExamplesOfPoT.AdbcConn)

# Verify the connection is active
IO.inspect(conn)
# => #PID<0.123.0>
```

#### Using the Connection for Metadata

ADBC works best for metadata operations and Arrow data operations:

```elixir
conn = Process.whereis(ExamplesOfPoT.AdbcConn)

# Get database information
{:ok, info} = Adbc.Connection.get_info(conn)
IO.inspect(info)

# Get database objects (tables, schemas, etc)
{:ok, objects} = Adbc.Connection.get_objects(conn, 0)
IO.inspect(objects)

# Get available table types
{:ok, table_types} = Adbc.Connection.get_table_types(conn)
IO.inspect(table_types)
```

#### Alternative: Using Postgres.Repo for Queries

For executing SQL queries, it's recommended to use the `Postgres.Repo` (Ecto) instead, which provides better SQL query support:

```elixir
# Using Postgres.Repo for SQL queries
alias Postgres.Repo

# Execute a raw SQL query
{:ok, result} = Repo.query("SELECT 1 as test_column, 'hello' as message")
IO.inspect(result)

# Query with parameters
{:ok, result} = Repo.query("SELECT * FROM users WHERE id = $1", [1])
IO.inspect(result)

# Query and map results
{:ok, result} = Repo.query("SELECT id, name FROM users LIMIT 10")
result.rows |> Enum.each(&IO.inspect/1)
```

#### Using Ecto Queries (Recommended for Data Access)

For the best developer experience, use Ecto queries:

```elixir
import Ecto.Query
alias Postgres.Repo

# Simple query
users = Repo.all(User)
IO.inspect(users)

# Filtered query
users = Repo.all(from u in User, where: u.id == ^1)
IO.inspect(users)

# With select clause
{:ok, result} = Repo.all(from u in User, select: {u.id, u.name}, limit: 10)
IO.inspect(result)
```

### ADBC Connection Metadata Functions

ADBC is optimized for metadata operations on Arrow data:

```elixir
conn = Process.whereis(ExamplesOfPoT.AdbcConn)

# Get connection info
Adbc.Connection.get_info(conn)
# => {:ok, result_set}

# Get available table types
Adbc.Connection.get_table_types(conn)
# => {:ok, result_set}

# Get database objects with depth 0 (all)
Adbc.Connection.get_objects(conn, 0)
# => {:ok, result_set}

# Set connection options
Adbc.Connection.set_option(conn, "option_name", "option_value")
# => :ok | {:error, reason}

# Get string option
Adbc.Connection.get_string_option(conn, "option_name")
# => {:ok, value} | {:error, reason}
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
