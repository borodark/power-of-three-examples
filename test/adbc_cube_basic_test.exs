defmodule Adbc.CubeBasicTest do
  use ExUnit.Case, async: true

  alias Adbc.{Connection, Result, Column}

  @moduletag :cube
  @moduletag timeout: 30_000

  # Path to our custom-built Cube driver
  @cube_driver_path Path.join(:code.priv_dir(:adbc),"lib/libadbc_driver_cube.so")


  # Cube server connection details
  @cube_host "localhost"
  @cube_port 4445
  @cube_token "test"

  setup_all do
    # Check if the Cube driver library exists
    unless File.exists?(@cube_driver_path) do
      raise "Cube driver not found at #{@cube_driver_path}. Run 'make' to build it."
    end

    # Check if cubesqld is running on the Arrow Native port
    case :gen_tcp.connect(String.to_charlist(@cube_host), @cube_port, [:binary], 1000) do
      {:ok, socket} ->
        :gen_tcp.close(socket)
        :ok

      {:error, :econnrefused} ->
        raise """
        Cube server (cubesqld) is not running on #{@cube_host}:#{@cube_port}.

        Start it with:
          cd ~/projects/learn_erl/cube/examples/recipes/arrow-ipc
          ./start-cube-api.sh    # Terminal 1
          ./start-cubesqld.sh    # Terminal 2
        """

      {:error, reason} ->
        raise "Failed to connect to Cube server: #{inspect(reason)}"
    end

    # Start connection pool for all tests
    pool_opts = [
      pool_size: 4,
      driver_path: @cube_driver_path,
      host: @cube_host,
      port: @cube_port,
      token: @cube_token
    ]

    {:ok, _pid} = start_supervised({Adbc.CubeTestPool, pool_opts})

    :ok
  end

  setup do
    # Get a connection from the pool for this test
    conn = Adbc.CubeTestPool.get_connection()

    %{conn: conn}
  end

  describe "basic connectivity" do
    test "runs simple SELECT 1 query", %{conn: conn} do
      assert {:ok, results} = Connection.query(conn, "SELECT 1 as test")

      materialized = Result.materialize(results)

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

    test "runs SELECT with different integer values", %{conn: conn} do
      assert {:ok, results} = Connection.query(conn, "SELECT 42 as answer")

      materialized = Result.materialize(results)

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
    test "handles STRING type", %{conn: conn} do
      assert {:ok, results} = Connection.query(conn, "SELECT 'hello world' as greeting")

      materialized = Result.materialize(results)

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

    test "handles DOUBLE/FLOAT type", %{conn: conn} do
      assert {:ok, results} = Connection.query(conn, "SELECT 3.14159 as pi")

      materialized = Result.materialize(results)

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

    test "handles BOOLEAN type", %{conn: conn} do
      assert {:ok, results} = Connection.query(conn, "SELECT true as flag")

      materialized = Result.materialize(results)

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
    test "queries Cube dimension", %{conn: conn} do
      query = """
      SELECT
      orders.FUL,
      MEASURE(orders.count),
      MEASURE(orders.subtotal_amount),
      MEASURE(orders.total_amount),
      MEASURE(orders.tax_amount)
      FROM
      orders
      GROUP BY
      1
      """

      assert {:ok, results} = Connection.query(conn, query)

      IO.inspect(Result.materialize(results))
      # df = DataFrame.from_query(conn, query,[])
      # IO.inspect(df)
    end
  end

  describe "connection pool" do
    test "pool provides multiple connections" do
      pool_size = Adbc.CubeTestPool.get_pool_size()
      assert pool_size == 4
    end

    test "can get specific connection from pool" do
      conn1 = Adbc.CubeTestPool.get_connection(1)
      conn2 = Adbc.CubeTestPool.get_connection(2)

      assert is_pid(conn1)
      assert is_pid(conn2)
      assert conn1 != conn2
    end

    test "concurrent queries work with pool" do
      # Run multiple queries concurrently
      tasks =
        for i <- 1..10 do
          Task.async(fn ->
            conn = Adbc.CubeTestPool.get_connection()
            Connection.query(conn, "SELECT #{i} as num")
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
        |> Enum.map(fn {:ok, result} ->
          %Result{data: [%Column{data: [value]}]} = Result.materialize(result)
          value
        end)
        |> Enum.sort()

      # Should get all values 1..10
      assert values == Enum.to_list(1..10)
    end
  end
end
