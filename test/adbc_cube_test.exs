defmodule Adbc.CubeTest do
  use ExUnit.Case, async: true

  alias Adbc.{Connection, Result, Column}

  @moduletag :cube
  @moduletag timeout: 30_000

  # Path to our custom-built Cube driver
  @cube_driver_path Path.join(:code.priv_dir(:adbc), "lib/libadbc_driver_cube.so")

  # Cube server connection details
  @cube_host "localhost"
  @cube_port 4445

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
    %{conn: Adbc.CubePool.get_connection()}
  end

  describe "basic queries" do
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

    test "runs SELECT with multiple columns", %{conn: conn} do
      assert {:ok, results} =
               Connection.query(conn, "SELECT 1 as id, 'test' as name, 3.14 as value")

      materialized = Result.materialize(results)

      assert %Result{data: columns} = materialized
      assert length(columns) == 3

      # Check column names
      column_names = Enum.map(columns, & &1.name)
      assert "id" in column_names
      assert "name" in column_names
      assert "value" in column_names
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

  describe "Cube-specific queries" do
    test "queries Cube dimension and measure", %{conn: conn} do
      query = """
      SELECT of_customers.brand, MEASURE(of_customers.count)
      FROM of_customers
      GROUP BY 1
      """

      assert {:ok, results} = Connection.query(conn, query)

      materialized = Result.materialize(results)

      assert %Result{data: [brand_col, count_col]} = materialized

      # Check brand column (dimension)
      assert %Column{
               name: "brand",
               type: :string,
               nullable: true
             } = brand_col

      # Check count column (measure)
      assert %Column{
               name: "measure(of_customers.count)",
               type: :s64,
               nullable: true
             } = count_col

      # Should have multiple rows
      assert length(brand_col.data) > 0
      assert length(count_col.data) == length(brand_col.data)

      # Verify some data
      assert is_binary(hd(brand_col.data))
      assert is_integer(hd(count_col.data))
    end

    test "queries with WHERE clause", %{conn: conn} do
      query = """
      SELECT of_customers.brand, MEASURE(of_customers.count)
      FROM of_customers
      WHERE of_customers.brand = 'Heineken'
      GROUP BY 1
      """

      assert {:ok, results} = Connection.query(conn, query)

      materialized = Result.materialize(results)

      assert %Result{data: [brand_col, count_col]} = materialized

      # Should have exactly 1 row for Heineken
      assert length(brand_col.data) == 1
      assert hd(brand_col.data) == "Heineken"
      assert is_integer(hd(count_col.data))
    end

    test "queries with ORDER BY", %{conn: conn} do
      query = """
      SELECT of_customers.brand, MEASURE(of_customers.count) as cnt
      FROM of_customers
      GROUP BY 1
      ORDER BY cnt DESC
      LIMIT 5
      """

      assert {:ok, results} = Connection.query(conn, query)

      materialized = Result.materialize(results)

      assert %Result{data: [brand_col, count_col]} = materialized

      # Should have at most 5 rows
      assert length(brand_col.data) <= 5

      # Counts should be in descending order
      counts = count_col.data
      sorted_counts = Enum.sort(counts, :desc)
      assert counts == sorted_counts
    end

    test "queries with LIMIT", %{conn: conn} do
      query = """
      SELECT of_customers.brand
      FROM of_customers
      GROUP BY 1
      LIMIT 10
      """

      assert {:ok, results} = Connection.query(conn, query)

      materialized = Result.materialize(results)

      assert %Result{data: [brand_col]} = materialized

      # Should have exactly 10 rows
      assert length(brand_col.data) == 10
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

    test "handles NULL values", %{conn: conn} do
      # This test depends on Cube data - may need adjustment
      assert {:ok, results} =
               Connection.query(conn, "SELECT of_customers.brand FROM of_customers LIMIT 1")

      materialized = Result.materialize(results)

      assert %Result{
               data: [
                 %Column{
                   nullable: true
                 }
               ]
             } = materialized
    end

    test "handles count", %{conn: conn} do
      # a MEASURE
      assert {:ok, %Adbc.Result{} = result} =
               Connection.query(conn, "SELECT MEASURE(of_customers.count) FROM of_customers")

      m_zd = result |> Adbc.Result.materialize()
      [column] = m_zd.data
      column |> IO.inspect()
      # one measure count with or without group by is one number 
      assert Enum.count(column.data) == 1
    end
  end

  describe "multiple rows" do
    test "returns multiple rows correctly", %{conn: conn} do
      query = """
      SELECT of_customers.brand
      FROM of_customers
      GROUP BY 1
      LIMIT 20
      """

      assert {:ok, results} = Connection.query(conn, query)

      materialized = Result.materialize(results)

      assert %Result{data: [brand_col]} = materialized

      # Should have 20 rows
      assert length(brand_col.data) == 20

      # All should be strings
      assert Enum.all?(brand_col.data, &is_binary/1)

      # Should have unique brands (because of GROUP BY)
      assert length(Enum.uniq(brand_col.data)) == 20
    end

    test "handles large result sets", %{conn: conn} do
      query = """
      SELECT of_customers.brand, MEASURE(of_customers.count)
      FROM of_customers
      GROUP BY 1
      """

      assert {:ok, results} = Connection.query(conn, query)

      materialized = Result.materialize(results)

      assert %Result{data: [brand_col, _count_col]} = materialized

      # Should have many rows (based on test data, typically 30+)
      assert length(brand_col.data) > 20
    end
  end

  describe "error handling" do
    # TODO implement error handling on cube side
    # @tag :todo
    test "handles invalid SQL syntax", %{conn: conn} do
      assert {:error, error} = Connection.query(conn, "SELECT * FORM invalid_table")

      assert Exception.message(error) =~ ~r/syntax|parse|error/i
    end

    #@tag :todo
    test "handles non-existent table", %{conn: conn} do
      # TODO implement error handling on cube side
      assert {:error, error} = Connection.query(conn, "SELECT 1 FROM non_existent_table")

      assert Exception.message(error) =~ ~r/table|not found|exist/i
    end
  end

  describe "connection management" do
    test "can create multiple connections" do
      conn1 = Adbc.CubePool.get_connection()
      conn2 = Adbc.CubePool.get_connection()

      assert {:ok, _} = Connection.query(conn1, "SELECT 1")
      assert {:ok, _} = Connection.query(conn2, "SELECT 2")
    end

    test "connection survives multiple queries", %{conn: conn} do
      for i <- 1..5 do
        assert {:ok, results} = Connection.query(conn, "SELECT #{i} as num")
        materialized = Result.materialize(results)
        assert %Result{data: [%Column{data: [^i]}]} = materialized
      end
    end
  end

  describe "performance" do
    @tag :slow
    test "handles concurrent queries" do
      # Run queries concurrently
      tasks =
      for conn <- 1..3 |> Enum.map(&Adbc.CubePool.get_connection/1) do
          Task.async(fn ->
            Connection.query(conn, "SELECT of_customers.brand FROM of_customers LIMIT 10")
          end)
        end

      # All should succeed
      results = Task.await_many(tasks, 10_000)
      assert Enum.all?(results, &match?({:ok, _}, &1))
    end
  end

  describe "Result module integration" do
    test "Result.materialize/1 works correctly", %{conn: conn} do
      {:ok, results} =
        Connection.query(conn, "SELECT 1 as a, 'test' as b, 3.14 as c")

      materialized = Result.materialize(results)

      assert %Result{} = materialized
      assert length(materialized.data) == 3
    end

    test "Result.to_map/1 works correctly", %{conn: conn} do
      {:ok, results} =
        Connection.query(conn, "SELECT 1 as id, 'Alice' as name")

      materialized = Result.materialize(results)
      map = Result.to_map(materialized)

      assert %{"id" => [1], "name" => ["Alice"]} = map
    end

    test "Result with Cube query data", %{conn: conn} do
      {:ok, results} =
        Connection.query(
          conn,
          "SELECT of_customers.brand, MEASURE(of_customers.count) FROM of_customers GROUP BY 1 LIMIT 3"
        )

      materialized = Result.materialize(results)
      map = Result.to_map(materialized)

      assert Map.has_key?(map, "brand")
      assert Map.has_key?(map, "measure(of_customers.count)")
      assert length(map["brand"]) == 3
      assert length(map["measure(of_customers.count)"]) == 3
    end
  end
end
