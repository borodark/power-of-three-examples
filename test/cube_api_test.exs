defmodule ExamplesOfPoTWeb.CubeApiControllerTest do
  use ExamplesOfPoTWeb.ConnCase

  # Note: Cube names match those defined in model/cubes/*.yaml
  # - of_customers (from of_customers.yaml)
  # - orders (from orders.yaml)

  describe "GET /cubejs-api/v1/meta" do
    test "returns cube metadata", %{conn: conn} do
      conn = get(conn, "/cubejs-api/v1/meta")
      assert json_response(conn, 200)

      response = json_response(conn, 200)
      assert is_map(response)
      assert Map.has_key?(response, "cubes")
    end

    test "returns extended metadata with ?extended=true", %{conn: conn} do
      conn = get(conn, "/cubejs-api/v1/meta", %{"extended" => "true"})
      response = json_response(conn, 200)

      assert is_map(response)
      assert Map.has_key?(response, "cubes")
      assert Map.has_key?(response, "compilerId")
      assert response["compilerId"] == "elixir-compiler-api"

      # Check that cubes have extended fields
      [cube | _] = response["cubes"]
      assert Map.has_key?(cube, "connectedComponent")
      assert Map.has_key?(cube, "type")
      assert cube["type"] == "cube"
    end
  end

  describe "POST /cubejs-api/v1/load" do
    test "executes a simple count query", %{conn: conn} do
      query = %{
        "measures" => ["of_customers.count"]
      }

      conn = post(conn, "/cubejs-api/v1/load", %{"query" => query})
      response = json_response(conn, 200)

      assert response["queryType"] == "regularQuery"
      assert is_list(response["results"])
    end

    test "executes query with dimensions", %{conn: conn} do
      query = %{
        "measures" => ["of_customers.count"],
        "dimensions" => ["of_customers.brand"]
      }

      conn = post(conn, "/cubejs-api/v1/load", %{"query" => query})
      response = json_response(conn, 200)

      assert response["queryType"] == "regularQuery"
      assert is_list(response["results"])

      [result | _] = response["results"]
      assert Map.has_key?(result, "annotation")
      assert Map.has_key?(result, "data")
    end

    test "handles orders query", %{conn: conn} do
      query = %{
        "measures" => ["orders.count"],
        "dimensions" => ["orders.brand_code"]
      }

      conn = post(conn, "/cubejs-api/v1/load", %{"query" => query})
      response = json_response(conn, 200)

      assert response["queryType"] == "regularQuery"
    end

    test "returns columnar JSON format", %{conn: conn} do
      query = %{
        "measures" => ["of_customers.count"],
        "dimensions" => ["of_customers.brand"]
      }

      conn = post(conn, "/cubejs-api/v1/load", %{"query" => query})
      response = json_response(conn, 200)

      [result | _] = response["results"]
      data = result["data"]

      # Columnar format: data is a map where each key is a column name
      # and values are arrays of all values for that column
      assert is_map(data)

      # Each column should be a list (not individual row values)
      Enum.each(data, fn {_col_name, values} ->
        assert is_list(values), "Expected columnar format with list values"
      end)

      # Verify we have both measure and dimension columns
      keys = Map.keys(data)
      assert length(keys) == 2, "Expected 2 columns (measure + dimension), got: #{inspect(keys)}"

      # Measure should be mapped to full cube member name
      assert "of_customers.count" in keys
    end

    test "handles filters", %{conn: conn} do
      query = %{
        "measures" => ["of_customers.count"],
        "dimensions" => ["of_customers.brand"],
        "filters" => [
          %{
            "member" => "of_customers.brand",
            "operator" => "equals",
            "values" => ["TEST"]
          }
        ]
      }

      conn = post(conn, "/cubejs-api/v1/load", %{"query" => query})
      response = json_response(conn, 200)

      assert response["queryType"] == "regularQuery"
    end

    test "returns error for invalid query", %{conn: conn} do
      query = %{
        "measures" => ["NonExistent.count"]
      }

      conn = post(conn, "/cubejs-api/v1/load", %{"query" => query})
      response = json_response(conn, 400)

      assert Map.has_key?(response, "error")
    end
  end

  describe "GET /cubejs-api/v1/load" do
    test "accepts query as URL parameter", %{conn: conn} do
      query = Jason.encode!(%{
        "measures" => ["of_customers.count"]
      })

      conn = get(conn, "/cubejs-api/v1/load", %{"query" => query})
      response = json_response(conn, 200)

      assert response["queryType"] == "regularQuery"
    end
  end
end
