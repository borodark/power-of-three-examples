#!/usr/bin/env elixir

# Integration test for PowerOfThree df/1 and df!/1 functions
# Tests with live Cube services

Mix.install([
  {:power_of_3, path: "../power-of-three"},
  {:adbc, github: "borodark/adbc", branch: "cleanup-take-II"},
  {:ecto_sql, "~> 3.10"}
])

IO.puts("\n=== PowerOfThree DataFrame Integration Test ===\n")

# Load the Customer module
Code.require_file("lib/pot_examples/customer.ex", __DIR__)

alias PotExamples.Customer

# Test 1: Check accessor modules exist
IO.puts("Test 1: Checking accessor modules...")
unless Code.ensure_loaded?(Customer.Measures), do: exit(:measures_module_not_loaded)
unless Code.ensure_loaded?(Customer.Dimensions), do: exit(:dimensions_module_not_loaded)
IO.puts("✓ Accessor modules loaded successfully")

# Test 2: Check accessor functions return correct refs
IO.puts("\nTest 2: Testing accessor functions...")
brand_dim = Customer.dimensions().brand()
count_measure = Customer.measures().count()

unless is_struct(brand_dim), do: exit(:invalid_dimension_ref)
unless is_struct(count_measure), do: exit(:invalid_measure_ref)
unless brand_dim.name == :brand, do: exit(:wrong_dimension_name)
unless count_measure.name == "count", do: exit(:wrong_measure_name)
IO.puts("✓ Accessor functions work correctly")
IO.puts("  Brand dimension: #{inspect(brand_dim)}")
IO.puts("  Count measure: #{inspect(count_measure)}")

# Test 3: Build a query using QueryBuilder
IO.puts("\nTest 3: Building SQL query...")
columns = [
  Customer.dimensions().brand(),
  Customer.dimensions().zodiac(),
  Customer.measures().count(),
  Customer.measures().aquarii()
]

sql = PowerOfThree.QueryBuilder.build(
  cube: "customer",
  columns: columns,
  limit: 10
)

IO.puts("Generated SQL:")
IO.puts(sql)
unless sql =~ "SELECT customer.brand", do: exit(:sql_missing_select)
unless sql =~ "MEASURE(customer.count)", do: exit(:sql_missing_measure)
unless sql =~ "GROUP BY 1, 2", do: exit(:sql_missing_groupby)
unless sql =~ "LIMIT 10", do: exit(:sql_missing_limit)
IO.puts("✓ SQL query built correctly")

# Test 4: Connect to Cube and execute query
IO.puts("\nTest 4: Connecting to Cube services...")

# Find the Cube driver
driver_path = Path.expand("_build/dev/lib/adbc/priv/lib/libadbc_driver_cube.so", __DIR__)

conn_opts = [
  host: "localhost",
  port: 4445,
  token: "test",
  driver_path: driver_path
]

IO.puts("Using driver: #{driver_path}")

case PowerOfThree.CubeConnection.connect(conn_opts) do
  {:ok, conn} ->
    IO.puts("✓ Connected to Cube successfully")

    # Test 5: Execute raw query
    IO.puts("\nTest 5: Executing raw query...")
    case PowerOfThree.CubeConnection.query(conn, "SELECT 1 as test") do
      {:ok, result} ->
        IO.puts("✓ Raw query executed successfully")
        IO.inspect(result, label: "Result")

      {:error, error} ->
        IO.puts("✗ Raw query failed:")
        IO.inspect(error)
        exit(:raw_query_failed)
    end

    # Test 6: Execute Cube query
    IO.puts("\nTest 6: Executing Cube query...")
    cube_sql = """
    SELECT
      of_customers.brand,
      MEASURE(of_customers.count)
    FROM of_customers
    GROUP BY 1
    LIMIT 5
    """

    case PowerOfThree.CubeConnection.query_to_map(conn, cube_sql) do
      {:ok, data} ->
        IO.puts("✓ Cube query executed successfully")
        IO.inspect(data, label: "Query result", limit: :infinity)

      {:error, error} ->
        IO.puts("✗ Cube query failed:")
        IO.inspect(error)
        exit(:cube_query_failed)
    end

    # Test 7: Use df/1 function
    IO.puts("\nTest 7: Testing df/1 function...")

    case Customer.df(
           columns: [
             Customer.dimensions().brand(),
             Customer.dimensions().zodiac(),
             Customer.measures().count()
           ],
           connection: conn,
           limit: 5
         ) do
      {:ok, result} ->
        IO.puts("✓ df/1 function works!")
        IO.puts("\nDataFrame result:")
        IO.inspect(result, label: "DataFrame", limit: :infinity)

        # Check result type
        if PowerOfThree.DataFrame.explorer_available?() do
          IO.puts("\n✓ Explorer is available - result is a DataFrame")
        else
          IO.puts("\n✓ Explorer not available - result is a map")
          unless is_map(result), do: exit(:result_not_a_map)
        end

      {:error, error} ->
        IO.puts("✗ df/1 function failed:")
        IO.inspect(error)
        exit(:df_function_failed)
    end

    # Test 8: Use df!/1 function (raising variant)
    IO.puts("\nTest 8: Testing df!/1 function...")

    result =
      Customer.df!(
        columns: [
          Customer.dimensions().brand(),
          Customer.measures().count(),
          Customer.measures().aquarii()
        ],
        connection: conn,
        where: "brand_code IS NOT NULL",
        order_by: [{2, :desc}],
        limit: 3
      )

    IO.puts("✓ df!/1 function works!")
    IO.puts("\nFiltered and ordered result:")
    IO.inspect(result, label: "Top brands by count", limit: :infinity)

    # Test 9: Query with all options
    IO.puts("\nTest 9: Testing with all query options...")

    result =
      Customer.df!(
        columns: [
          Customer.dimensions().zodiac(),
          Customer.measures().count()
        ],
        connection: conn,
        where: "zodiac != 'Professor Abe Weissman'",
        order_by: [{2, :desc}],
        limit: 5,
        offset: 0
      )

    IO.puts("✓ Complex query works!")
    IO.puts("\nTop 5 zodiac signs by count:")
    IO.inspect(result, label: "Zodiac distribution", limit: :infinity)

    IO.puts("\n=== All Tests Passed! ===\n")

  {:error, error} ->
    IO.puts("✗ Failed to connect to Cube:")
    IO.inspect(error)
    IO.puts("\nMake sure Cube services are running:")
    IO.puts("  - cubesqld on port 4445")
    IO.puts("  - Cube API on port 4008")
    IO.puts("  - PostgreSQL on port 7432")
    exit(:connection_failed)
end
