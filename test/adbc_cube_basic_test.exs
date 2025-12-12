defmodule Adbc.CubeBasicTest do
  use ExUnit.Case, async: true

  alias Adbc.{Connection, Result, Column}
  alias ExamplesOfPoT.CubePool

  @moduletag :cube
  @moduletag timeout: 30_000

  # Path to our custom-built Cube driver
  @cube_driver_path "priv/lib/libadbc_driver_cube.so"

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

    :ok
  end

  setup do
    %{conn: CubePool.get_connection()}
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
        """,
        """
        SELECT
        of_addresses.kind,
        of_addresses.given_name,
        MEASURE(of_addresses.country_count)
        FROM
        of_addresses
        GROUP BY
        1,
        2
        """,
        """
        SELECT
        of_addresses.kind,
        of_addresses.country_bm,
        MEASURE(of_addresses.count_of_records)
        FROM
        of_addresses
        GROUP BY
        1,
        2
        """,
        """
        SELECT
        orders.FUL,
        orders.brand,
        orders.market_code,
        MEASURE(orders.count),
        MEASURE(orders.subtotal_amount),
        MEASURE(orders.total_amount)
        FROM
        orders
        GROUP BY
        1,
        2,
        3
        """,
        """
        SELECT
        of_customers.zodiac,
        of_customers.brand,
        MEASURE(of_customers.emails_distinct)
        FROM
        of_customers
        GROUP BY
        1,
        2
        """,
        """
        SELECT
        of_addresses.given_name,
        MEASURE(of_addresses.count_of_records)
        FROM
        of_addresses
        GROUP BY
        1
        """

      ]

      for query <- queries do
        df = Explorer.DataFrame.from_query(conn, query, [])
        IO.inspect(df)
      end
    end
  end
end
