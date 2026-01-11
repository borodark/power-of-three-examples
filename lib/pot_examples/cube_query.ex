defmodule ExamplesOfPoT.CubeQuery do
  @moduledoc """
  Helper module for querying Cube via ADBC connection pool.

  Provides convenient functions for common Cube query patterns.

  ## Examples

      # Simple query
      {:ok, result} = CubeQuery.query("SELECT 1 as test")

      # Query with result materialization
      result = CubeQuery.query!("SELECT * FROM of_customers LIMIT 10")
      |> CubeQuery.to_map()

      # Query Cube dimensions and measures
      customers_by_brand = CubeQuery.query_cube(
        cube: "of_customers",
        dimensions: ["brand"],
        measures: ["count"],
        limit: 10
      )
  """

  alias PowerOfThree.CubeConnectionPool
  alias Adbc.Result

  @doc """
  Executes a SQL query and returns the raw result.

  ## Examples

      iex> CubeQuery.query("SELECT 1 as test")
      {:ok, %Adbc.Result{...}}
  """
  def query(sql, params \\ []) do
    CubeConnectionPool.query(sql, params)
  end

  @doc """
  Executes a SQL query and raises on error.

  ## Examples

      iex> CubeQuery.query!("SELECT 1 as test")
      %Adbc.Result{...}
  """
  def query!(sql, params \\ []) do
    case query(sql, params) do
      {:ok, result} -> result
      {:error, error} -> raise "Query failed: #{inspect(error)}"
    end
  end

  @doc """
  Executes a query and materializes the result.

  ## Examples

      iex> CubeQuery.query_materialized("SELECT 1 as test")
      {:ok, %Adbc.Result{data: [%Adbc.Column{...}]}}
  """
  def query_materialized(sql, params \\ []) do
    query(sql, params)
  end

  @doc """
  Executes a query, materializes, and converts to map format.

  Returns a map where keys are column names and values are lists of data.

  ## Examples

      iex> CubeQuery.to_map(result)
      %{"test" => [1]}

      iex> CubeQuery.query!("SELECT 1 as a, 2 as b") |> CubeQuery.to_map()
      %{"a" => [1], "b" => [2]}
  """
  def to_map(%Result{} = result) do
    materialized = Result.materialize(result)
    Result.to_map(materialized)
  end

  def to_map(sql) when is_binary(sql) do
    sql
    |> query!()
    |> to_map()
  end

  @doc """
  Builds and executes a Cube query with dimensions and measures.

  ## Options

    * `:cube` - The cube name (required)
    * `:dimensions` - List of dimension names
    * `:measures` - List of measure names
    * `:where` - WHERE clause (optional)
    * `:order_by` - ORDER BY clause (optional)
    * `:limit` - LIMIT value (optional)
    * `:offset` - OFFSET value (optional)

  ## Examples

      iex> CubeQuery.query_cube(
      ...>   cube: "of_customers",
      ...>   dimensions: ["brand", "city"],
      ...>   measures: ["count"],
      ...>   limit: 10
      ...> )
      {:ok, %{"brand" => [...], "city" => [...], "measure(of_customers.count)" => [...]}}
  """
  def query_cube(opts) do
    cube = Keyword.fetch!(opts, :cube)
    dimensions = Keyword.get(opts, :dimensions, [])
    measures = Keyword.get(opts, :measures, [])
    where = Keyword.get(opts, :where)
    order_by = Keyword.get(opts, :order_by)
    limit = Keyword.get(opts, :limit)
    offset = Keyword.get(opts, :offset)

    sql = build_cube_sql(cube, dimensions, measures, where, order_by, limit, offset)

    case query_materialized(sql) do
      {:ok, materialized} -> {:ok, Result.to_map(materialized)}
      error -> error
    end
  end

  @doc """
  Same as `query_cube/1` but raises on error.
  """
  def query_cube!(opts) do
    case query_cube(opts) do
      {:ok, result} -> result
      {:error, error} -> raise "Cube query failed: #{inspect(error)}"
    end
  end

  # Private helpers

  defp build_cube_sql(cube, dimensions, measures, where, order_by, limit, offset) do
    # Build SELECT clause
    select_items =
      (Enum.map(dimensions, &"#{cube}.#{&1}") ++
         Enum.map(measures, &"MEASURE(#{cube}.#{&1})"))
      |> Enum.join(", ")

    select_clause = "SELECT #{select_items}"

    # Build FROM clause
    from_clause = "FROM #{cube}"

    # Build WHERE clause
    where_clause = if where, do: "WHERE #{where}", else: nil

    # Build GROUP BY clause (if we have dimensions)
    group_by_clause =
      if length(dimensions) > 0 do
        indices = Enum.map(1..length(dimensions), &Integer.to_string/1)
        "GROUP BY #{Enum.join(indices, ", ")}"
      else
        nil
      end

    # Build ORDER BY clause
    order_by_clause = if order_by, do: "ORDER BY #{order_by}", else: nil

    # Build LIMIT clause
    limit_clause = if limit, do: "LIMIT #{limit}", else: nil

    # Build OFFSET clause
    offset_clause = if offset, do: "OFFSET #{offset}", else: nil

    # Combine all clauses
    [
      select_clause,
      from_clause,
      where_clause,
      group_by_clause,
      order_by_clause,
      limit_clause,
      offset_clause
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join("\n")
  end

  @doc """
  Queries the Cube metadata to get available cubes.

  ## Examples

      iex> CubeQuery.list_cubes()
      {:ok, ["of_customers", "orders", ...]}
  """
  def list_cubes do
    case query_materialized("SHOW CUBES") do
      {:ok, materialized} ->
        cubes =
          materialized
          |> Result.to_map()
          |> Map.get("cube_name", [])

        {:ok, cubes}

      error ->
        error
    end
  end

  @doc """
  Gets information about a specific cube.

  ## Examples

      iex> CubeQuery.describe_cube("of_customers")
      {:ok, %{dimensions: [...], measures: [...]}}
  """
  def describe_cube(cube_name) do
    case query_materialized("SHOW #{cube_name}") do
      {:ok, materialized} -> {:ok, Result.to_map(materialized)}
      error -> error
    end
  end
end
