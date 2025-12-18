defmodule ExamplesOfPoT.CubePoolTest do
  use ExUnit.Case

  alias Adbc.CubePool
  alias Adbc.{Connection, Result, Column}

  @moduletag :cube
  @moduletag timeout: 30_000

  describe "pool management" do
    test "pool is started with configured size" do
      pool_size = CubePool.get_pool_size()
      expected_size = 44
      assert pool_size == expected_size
    end

    test "can get connections from pool" do
      conn = CubePool.get_connection()
      assert is_pid(conn)
      assert Process.alive?(conn)
    end

    test "can get specific connection by index" do
      conn1 = CubePool.get_connection(1)
      conn2 = CubePool.get_connection(2)

      assert is_pid(conn1)
      assert is_pid(conn2)
      assert conn1 != conn2
    end

    test "round-robin distributes connections" do
      connections =
        for _ <- 1..10 do
          CubePool.get_connection()
        end

      # Should have multiple different connections
      unique_connections = Enum.uniq(connections)
      assert length(unique_connections) > 1
    end
  end

  describe "query execution" do
    test "executes simple SELECT query via pool" do
      assert {:ok, results} = CubePool.get_connection() |> Connection.query("SELECT 1 as test")

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

    test "executes query with different values" do
      assert {:ok, results} = CubePool.get_connection() |> Connection.query("SELECT 42 as answer")

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

    test "handles STRING type" do
      assert {:ok, results} =
               CubePool.get_connection() |> Connection.query("SELECT 'hello cube' as greeting")

      materialized = Result.materialize(results)

      assert %Result{
               data: [
                 %Column{
                   name: "greeting",
                   type: :string,
                   data: ["hello cube"]
                 }
               ]
             } = materialized
    end

    test "handles BOOLEAN type" do
      assert {:ok, results} = CubePool.get_connection() |> Connection.query("SELECT true as flag")

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

    test "handles DOUBLE type" do
      assert {:ok, results} =
               CubePool.get_connection() |> Connection.query("SELECT 3.14159 as pi")

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

      assert type in [:f64, :f32]
      assert is_float(pi_value)
      assert_in_delta pi_value, 3.14159, 0.00001
    end
  end

  describe "concurrent queries" do
    test "handles concurrent queries from pool" do
      # Run 10 queries concurrently
      tasks =
        for i <- 1..10 do
          Task.async(fn ->
            CubePool.get_connection() |> Connection.query("SELECT #{i} as num")
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

  describe "connection via specific connection" do
    test "can query using specific connection from pool" do
      conn = CubePool.get_connection(1)

      assert {:ok, results} = Connection.query(conn, "SELECT 99 as value")

      materialized = Result.materialize(results)

      assert %Result{
               data: [
                 %Column{
                   name: "value",
                   type: :s64,
                   data: [99]
                 }
               ]
             } = materialized
    end

    test "queries Cube dimension" do
      queries = [
        """
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
        """,
        """
        SELECT
        orders.FIN,
        orders.FUL,
        MEASURE(orders.count),
        MEASURE(orders.subtotal_amount),
        MEASURE(orders.total_amount),
        MEASURE(orders.tax_amount)
        FROM
        orders
        GROUP BY
        1,
        2
        """
      ]

      for query <- queries do
        with conn <- CubePool.get_connection() do
          df = Explorer.DataFrame.from_query(conn, query, [])
          IO.inspect(df)
        end
      end
    end
  end
end
