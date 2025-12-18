defmodule Adbc.DatatypeTest do
  use ExUnit.Case
  alias Adbc.Connection

  setup do
    conn = Adbc.CubePool.get_connection()
    {:ok, conn: conn}
  end

  describe "integer types" do
    test "handles INT8/SMALLINT", %{conn: conn} do
      {:ok, result} = Connection.query(conn, "SELECT int8_val FROM datatypes_test")

      assert %Adbc.Result{data: data} = result
      assert length(data) > 0

      # Check the column exists and has integer values
      [first_row | _] = data
      assert is_map(first_row)
      assert Map.has_key?(first_row, "int8_val")
    end

    test "handles INT16/SMALLINT", %{conn: conn} do
      {:ok, result} = Connection.query(conn, "SELECT int16_val FROM datatypes_test")

      assert %Adbc.Result{data: data} = result
      assert length(data) > 0
    end

    test "handles INT32/INTEGER", %{conn: conn} do
      {:ok, result} = Connection.query(conn, "SELECT int32_val FROM datatypes_test")

      assert %Adbc.Result{data: data} = result
      assert length(data) > 0

      # Verify we can access the values
      [first_row | _] = data
      int32_val = Map.get(first_row, "int32_val")
      assert is_integer(int32_val)
    end

    test "handles INT64/BIGINT", %{conn: conn} do
      {:ok, result} = Connection.query(conn, "SELECT int64_val FROM datatypes_test")

      assert %Adbc.Result{data: data} = result
      assert length(data) > 0

      [first_row | _] = data
      int64_val = Map.get(first_row, "int64_val")
      assert is_integer(int64_val)
    end

    test "handles UINT8", %{conn: conn} do
      {:ok, result} = Connection.query(conn, "SELECT uint8_val FROM datatypes_test")

      assert %Adbc.Result{data: data} = result
      assert length(data) > 0
    end

    test "handles UINT16", %{conn: conn} do
      {:ok, result} = Connection.query(conn, "SELECT uint16_val FROM datatypes_test")

      assert %Adbc.Result{data: data} = result
      assert length(data) > 0
    end

    test "handles UINT32", %{conn: conn} do
      {:ok, result} = Connection.query(conn, "SELECT uint32_val FROM datatypes_test")

      assert %Adbc.Result{data: data} = result
      assert length(data) > 0
    end

    test "handles UINT64", %{conn: conn} do
      {:ok, result} = Connection.query(conn, "SELECT uint64_val FROM datatypes_test")

      assert %Adbc.Result{data: data} = result
      assert length(data) > 0
    end
  end

  describe "float types" do
    test "handles FLOAT/REAL", %{conn: conn} do
      {:ok, result} = Connection.query(conn, "SELECT float32_val FROM datatypes_test")

      assert %Adbc.Result{data: data} = result
      assert length(data) > 0

      [first_row | _] = data
      float32_val = Map.get(first_row, "float32_val")
      assert is_float(float32_val) or is_integer(float32_val)
    end

    test "handles DOUBLE PRECISION", %{conn: conn} do
      {:ok, result} = Connection.query(conn, "SELECT float64_val FROM datatypes_test")

      assert %Adbc.Result{data: data} = result
      assert length(data) > 0

      [first_row | _] = data
      float64_val = Map.get(first_row, "float64_val")
      assert is_float(float64_val) or is_integer(float64_val)
    end
  end

  describe "all integer and float types together" do
    test "handles query with all numeric types", %{conn: conn} do
      {:ok, result} = Connection.query(conn, """
        SELECT
          int8_val, int16_val, int32_val, int64_val,
          uint8_val, uint16_val, uint32_val, uint64_val,
          float32_val, float64_val
        FROM datatypes_test
        LIMIT 1
      """)

      assert %Adbc.Result{data: data} = result
      assert length(data) == 1

      [row] = data

      # Verify all columns are present
      assert Map.has_key?(row, "int8_val")
      assert Map.has_key?(row, "int16_val")
      assert Map.has_key?(row, "int32_val")
      assert Map.has_key?(row, "int64_val")
      assert Map.has_key?(row, "uint8_val")
      assert Map.has_key?(row, "uint16_val")
      assert Map.has_key?(row, "uint32_val")
      assert Map.has_key?(row, "uint64_val")
      assert Map.has_key?(row, "float32_val")
      assert Map.has_key?(row, "float64_val")

      IO.puts("\\nInteger and Float Types Test Results:")
      IO.inspect(row, label: "Row data")
    end
  end

  describe "date/time types" do
    test "handles DATE type", %{conn: conn} do
      {:ok, result} = Connection.query(conn, "SELECT date_val FROM datatypes_test")

      assert %Adbc.Result{data: data} = result
      assert length(data) > 0

      [first_row | _] = data
      assert Map.has_key?(first_row, "date_val")
      IO.puts("\\nDATE Type Test:")
      IO.inspect(Map.get(first_row, "date_val"), label: "date_val")
    end

    test "handles TIMESTAMP type", %{conn: conn} do
      {:ok, result} = Connection.query(conn, "SELECT timestamp_val FROM datatypes_test")

      assert %Adbc.Result{data: data} = result
      assert length(data) > 0

      [first_row | _] = data
      assert Map.has_key?(first_row, "timestamp_val")
      IO.puts("\\nTIMESTAMP Type Test:")
      IO.inspect(Map.get(first_row, "timestamp_val"), label: "timestamp_val")
    end

    test "handles query with all date/time types", %{conn: conn} do
      {:ok, result} = Connection.query(conn, """
        SELECT
          date_val,
          timestamp_val
        FROM datatypes_test
        LIMIT 1
      """)

      assert %Adbc.Result{data: data} = result
      assert length(data) == 1

      [row] = data

      # Verify all columns are present
      assert Map.has_key?(row, "date_val")
      assert Map.has_key?(row, "timestamp_val")

      IO.puts("\\nDate/Time Types Test Results:")
      IO.inspect(row, label: "Row data")
    end
  end

  describe "all types together" do
    test "handles query with all supported types", %{conn: conn} do
      {:ok, result} = Connection.query(conn, """
        SELECT
          int8_val, int16_val, int32_val, int64_val,
          uint8_val, uint16_val, uint32_val, uint64_val,
          float32_val, float64_val,
          date_val, timestamp_val,
          bool_val, string_val
        FROM datatypes_test
        LIMIT 1
      """)

      assert %Adbc.Result{data: data} = result
      assert length(data) == 1

      [row] = data

      IO.puts("\\nAll Supported Types Test Results:")
      IO.inspect(row, label: "Row data with all types")
    end
  end
end
