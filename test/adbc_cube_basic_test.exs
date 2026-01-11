defmodule Adbc.CubeBasicTest do
  use ExUnit.Case, async: true

  alias Adbc.{Result, Column}
  alias Explorer.DataFrame
  alias PowerOfThree.CubeConnectionPool

  @moduletag :cube
  @moduletag timeout: 30_000

  # Cube server connection details
  @cube_host "localhost"
  @cube_port 8120

  setup_all do
    # Ensure the Cube driver is available
    driver_version =
      Application.get_env(:power_of_3, PowerOfThree.CubeConnectionPool, [])
      |> Keyword.get(:driver_version)

    driver_opts = if driver_version, do: [version: driver_version], else: []

    case Adbc.Driver.so_path(:cube, driver_opts) do
      {:ok, _path} ->
        :ok

      {:error, reason} ->
        raise """
        Cube driver not available: #{reason}

        Ensure config :adbc, :drivers, [:cube] is set and recompile dependencies.
        """
    end

    # Check if cubesqld is running on the Arrow Native port
    case :gen_tcp.connect(String.to_charlist(@cube_host), @cube_port, [:binary], 1000) do
      {:ok, socket} ->
        :gen_tcp.close(socket)
        :ok

      {:error, :econnrefused} ->
        raise """
        Cube server (cubesqld) is not running on #{@cube_host}:#{@cube_port}.
        """

      {:error, reason} ->
        raise "Failed to connect to Cube server: #{inspect(reason)}"
    end

    :ok
  end

  describe "basic connectivity" do
    test "runs simple SELECT 1 query" do
      assert {:ok, materialized} = CubeConnectionPool.query("SELECT 1 as test")

      assert %Result{
               data: [
                 %Column{
                   name: "test",
                   type: :s64,
                   nullable: false,
                   data: [1]
                 }
               ]
             } = materialized
    end

    test "runs SELECT with different integer values" do
      assert {:ok, materialized} = CubeConnectionPool.query("SELECT 42 as answer")

      assert %Result{
               data: [
                 %Column{
                   name: "answer",
                   type: :s64,
                   data: [42]
                 }
               ]
             } = materialized
    end
  end

  describe "data types" do
    test "handles STRING type" do
      assert {:ok, materialized} = CubeConnectionPool.query("SELECT 'hello world' as greeting")

      assert %Result{
               data: [
                 %Column{
                   name: "greeting",
                   type: :string,
                   data: ["hello world"]
                 }
               ]
             } = materialized
    end

    test "handles DOUBLE/FLOAT type" do
      assert {:ok, materialized} = CubeConnectionPool.query("SELECT 3.14159 as pi")

      assert %Result{
               data: [
                 %Column{
                   name: "pi",
                   type: type,
                   data: [pi_value]
                 }
               ]
             } = materialized

      # Type could be :f64 or :f32 depending on Arrow schema
      assert type in [:f64, :f32]
      assert is_float(pi_value)
      assert_in_delta pi_value, 3.14159, 0.00001
    end

    test "handles BOOLEAN type" do
      assert {:ok, materialized} = CubeConnectionPool.query("SELECT true as flag")

      assert %Result{
               data: [
                 %Column{
                   name: "flag",
                   type: :boolean,
                   data: [true]
                 }
               ]
             } = materialized
    end
  end

  describe "Cube queries" do
    test "queries Cube dimension" do
      queries = [
        """
        SELECT
        orders_with_preagg.brand_code,
        orders_with_preagg.market_code,
        DATE_TRUNC('week', orders_with_preagg.updated_at),
        MEASURE(orders_with_preagg.subtotal_amount_sum),
        MEASURE(orders_with_preagg.total_amount_sum),
        MEASURE(orders_with_preagg.tax_amount_sum),
        MEASURE(orders_with_preagg.count)
        FROM
        orders_with_preagg
        GROUP BY
        1,
        2,
        3
        LIMIT 50000
        """,
        """
        SELECT
        datatypes_test.float32_col,
        datatypes_test.bool_col,
        datatypes_test.float64_col,
        datatypes_test.int16_col,
        datatypes_test.int32_col,
        datatypes_test.int64_col,
        datatypes_test.int8_col,
        datatypes_test.uint16_col,
        datatypes_test.uint32_col,
        datatypes_test.uint64_col,
        datatypes_test.uint8_col,
        datatypes_test.string_col,
        MEASURE(datatypes_test.float64_avg),
        MEASURE(datatypes_test.int32_sum)
        FROM
        datatypes_test
        GROUP BY
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        10,
        11,
        12
        LIMIT
        10000
        """
      ]

      for query <- queries do
        assert {:ok, results} = CubeConnectionPool.query(query)
        [col1 | _] = results.data
        IO.inspect(col1.data)
        IO.inspect(Enum.count(col1.data))
        df = CubeConnectionPool.transaction(fn conn -> DataFrame.from_query!(conn, query, []) end)
        IO.inspect(df)
      end
    end
  end

  describe "connection pool" do
    test "pool provides multiple connections" do
      pool_config = Application.get_env(:power_of_3, PowerOfThree.CubeConnectionPool, [])
      expected_size = Keyword.get(pool_config, :size, System.schedulers_online() * 2)
      {_state, workers, _overflow, _busy, _waiting} = CubeConnectionPool.status()
      assert workers == expected_size
    end

    test "can get specific connection from pool" do
      {worker1, conn1} = CubeConnectionPool.checkout()
      {worker2, conn2} = CubeConnectionPool.checkout()

      assert is_pid(worker1)
      assert is_pid(worker2)
      assert is_pid(conn1)
      assert is_pid(conn2)
      assert conn1 != conn2

      CubeConnectionPool.checkin(worker1)
      CubeConnectionPool.checkin(worker2)
    end

    test "concurrent queries work with pool" do
      # Run multiple queries concurrently
      tasks =
        for i <- 1..10 do
          Task.async(fn ->
            CubeConnectionPool.query("SELECT #{i} as num")
          end)
        end

      results = Task.await_many(tasks, 10_000)

      # All should succeed
      assert Enum.all?(results, fn
               {:ok, _} -> true
               _ -> false
             end)

      # Extract values
      values =
        results
        |> Enum.map(fn {:ok, %Result{data: [%Column{data: [value]}]}} -> value end)
        |> Enum.sort()

      # Should get all values 1..10
      assert values == Enum.to_list(1..10)
    end
  end
end
