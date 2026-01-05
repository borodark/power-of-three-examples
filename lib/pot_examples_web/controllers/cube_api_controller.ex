defmodule ExamplesOfPoTWeb.CubeApiController do
  @moduledoc """
  Phoenix controller implementing the Cube.js `/cubejs-api/v1/load` endpoint.

  This provides a drop-in replacement for the Cube HTTP API using:
  - CompilerApi for semantic query compilation to SQL
  - Explorer/ADBC for high-performance query execution
  - PostgreSQL as the underlying data store

  ## Columnar JSON Response

  Results are returned in columnar format for efficiency:

      %{
        "data" => %{
          "Orders.count" => [42, 38, 25],
          "Orders.status" => ["completed", "pending", "cancelled"]
        }
      }

  This format aligns with Arrow's columnar model, reducing serialization overhead
  and enabling efficient client-side processing.
  """

  use ExamplesOfPoTWeb, :controller

  require Logger

  alias Explorer.DataFrame
  alias Explorer.Series

  @doc """
  Handles POST requests to /cubejs-api/v1/load

  Expects JSON body with Cube query format:
  ```json
  {
    "query": {
      "measures": ["Orders.count"],
      "dimensions": ["Orders.status"],
      "filters": [...],
      "timeDimensions": [...]
    }
  }
  ```
  """
  def load(conn, params) do
    query = extract_query(params)
    request_id = get_request_id(conn)

    case execute_cube_query(query) do
      {:ok, result} ->
        response = build_cube_response(query, result, request_id)
        json(conn, response)

      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: reason, requestId: request_id})
    end
  end

  @doc """
  Returns metadata about available cubes, measures, and dimensions.
  GET /cubejs-api/v1/meta
  GET /cubejs-api/v1/meta?extended=true
  """
  def meta(conn, params) do
    extended = params["extended"] == "true"

    case get_compiler_api() do
      {:ok, api} ->
        case CompilerApi.meta_config(api) do
          {:ok, metadata} ->
            response = if extended, do: build_extended_metadata(metadata), else: metadata
            json(conn, response)

          {:error, reason} ->
            conn
            |> put_status(:internal_server_error)
            |> json(%{error: reason})
        end

      {:error, reason} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: reason})
    end
  end

  defp build_extended_metadata(metadata) do
    # Extended metadata includes additional information like:
    # - Full SQL definitions for measures/dimensions
    # - Meta information (ecto_field, ecto_type)
    # - Descriptions and titles
    cubes =
      (metadata["cubes"] || [])
      |> Enum.map(fn cube ->
        cube
        |> Map.put("connectedComponent", 1)
        |> Map.put("type", "cube")
        |> extend_measures(cube["measures"] || [])
        |> extend_dimensions(cube["dimensions"] || [])
      end)

    %{
      "cubes" => cubes,
      "compilerId" => "elixir-compiler-api",
      "schemaVersion" => 1
    }
  end

  defp extend_measures(cube, measures) do
    extended_measures =
      measures
      |> Enum.map(fn measure ->
        measure
        |> Map.put("isVisible", true)
        |> Map.put("public", true)
        |> Map.put("cumulative", false)
        |> Map.put("cumulativeTotal", false)
        |> Map.put("rollingWindow", nil)
        |> Map.put("drillMembers", [])
        |> Map.put("drillMembersGrouped", %{"measures" => [], "dimensions" => []})
      end)

    Map.put(cube, "measures", extended_measures)
  end

  defp extend_dimensions(cube, dimensions) do
    extended_dimensions =
      dimensions
      |> Enum.map(fn dimension ->
        dimension
        |> Map.put("isVisible", true)
        |> Map.put("public", true)
        |> Map.put("primaryKey", dimension["primaryKey"] || false)
        |> Map.put("suggestFilterValues", true)
      end)

    Map.put(cube, "dimensions", extended_dimensions)
  end

  # Private functions

  defp extract_query(%{"query" => query}) when is_binary(query) do
    case Jason.decode(query) do
      {:ok, decoded} -> decoded
      {:error, _} -> %{}
    end
  end

  defp extract_query(%{"query" => query}) when is_map(query), do: query
  defp extract_query(params) when is_map(params), do: params
  defp extract_query(_), do: %{}

  defp get_request_id(conn) do
    case get_req_header(conn, "x-request-id") do
      [id | _] -> id
      [] -> generate_request_id()
    end
  end

  defp generate_request_id do
    :crypto.strong_rand_bytes(8)
    |> Base.encode16(case: :lower)
  end

  defp get_compiler_api do
    schema_path = Application.get_env(:pot_examples, :schema_path, "model/cubes")

    CompilerApi.new(
      schema_path: schema_path,
      cache_ttl: 600
    )
  end

  defp execute_cube_query(query) do
    with {:ok, api} <- get_compiler_api(),
         {:ok, sql, params} <- CompilerApi.get_sql(api, query) do
      Logger.debug("Generated SQL: #{sql}")
      Logger.debug("Params: #{inspect(params)}")

      execute_sql(sql, params)
    end
  end

  defp execute_sql(sql, params) do
    # Execute via Postgres.Repo with Postgrex
    case Postgres.Repo.query(sql, params) do
      {:ok, %Postgrex.Result{columns: columns, rows: rows}} ->
        # Convert to Explorer DataFrame for native columnar format
        df = rows_to_dataframe(columns, rows)
        {:ok, %{columns: columns, dataframe: df}}

      {:error, %Postgrex.Error{} = error} ->
        Logger.error("Query execution failed: #{inspect(error)}")
        {:error, format_db_error(error)}

      {:error, reason} ->
        Logger.error("Query execution failed: #{inspect(reason)}")
        {:error, "Query execution failed"}
    end
  end

  # Convert Postgrex rows to Explorer DataFrame (columnar format)
  defp rows_to_dataframe(columns, rows) when rows == [] do
    # Empty result - create empty DataFrame with column names
    columns
    |> Enum.map(fn col -> {col, []} end)
    |> DataFrame.new()
  end

  defp rows_to_dataframe(columns, rows) do
    # Transpose rows to columns and create DataFrame
    columns
    |> Enum.with_index()
    |> Enum.map(fn {col_name, idx} ->
      values = Enum.map(rows, fn row -> Enum.at(row, idx) end)
      {col_name, values}
    end)
    |> DataFrame.new()
  end

  defp format_db_error(%Postgrex.Error{postgres: %{message: message}}) do
    "Database error: #{message}"
  end

  defp format_db_error(_), do: "Database query failed"

  defp build_cube_response(query, %{columns: columns, dataframe: df}, request_id) do
    measures = query["measures"] || query[:measures] || []
    dimensions = query["dimensions"] || query[:dimensions] || []
    time_dimensions = query["timeDimensions"] || query[:timeDimensions] || []

    # Convert DataFrame to columnar map with formatted column names
    # This leverages Explorer's native Arrow-backed columnar storage
    data =
      columns
      |> Enum.reduce(%{}, fn col, acc ->
        formatted_name = format_column_name(col, dimensions, measures, time_dimensions)
        series = df[col]

        # Convert Series to list with proper value formatting
        values =
          series
          |> Series.to_list()
          |> Enum.map(&format_value/1)

        Map.put(acc, formatted_name, values)
      end)

    # Build annotation metadata
    annotation = build_annotation(dimensions, measures, time_dimensions)

    %{
      "queryType" => "regularQuery",
      "results" => [
        %{
          "annotation" => annotation,
          "data" => data,
          "query" => query,
          "lastRefreshTime" => DateTime.utc_now() |> DateTime.to_iso8601(),
          "external" => false,
          "dbType" => "postgres",
          "extDbType" => "postgres",
          "requestId" => request_id,
          "usedPreAggregations" => %{}
        }
      ],
      "pivotQuery" => %{
        "measures" => measures,
        "dimensions" => dimensions,
        "timeDimensions" => time_dimensions
      }
    }
  end

  defp format_column_name(col, dimensions, measures, time_dimensions) do
    # Try to match column to original dimension/measure name
    all_members = dimensions ++ measures ++ extract_time_dimension_names(time_dimensions)

    Enum.find(all_members, col, fn member ->
      member_field =
        member
        |> String.split(".")
        |> List.last()
        |> String.downcase()

      String.downcase(col) == member_field
    end)
  end

  defp extract_time_dimension_names(time_dimensions) do
    Enum.map(time_dimensions, fn
      %{"dimension" => dim} -> dim
      dim when is_binary(dim) -> dim
      _ -> nil
    end)
    |> Enum.filter(&(&1 != nil))
  end

  defp format_value(%NaiveDateTime{} = dt), do: NaiveDateTime.to_iso8601(dt)
  defp format_value(%DateTime{} = dt), do: DateTime.to_iso8601(dt)
  defp format_value(%Date{} = d), do: Date.to_iso8601(d)
  defp format_value(%Decimal{} = d), do: Decimal.to_float(d)
  defp format_value(value), do: value

  defp build_annotation(dimensions, measures, time_dimensions) do
    dimension_annotations =
      dimensions
      |> Enum.into(%{}, fn dim ->
        {dim,
         %{
           "title" => humanize_member(dim),
           "shortTitle" => short_title(dim),
           "type" => "string"
         }}
      end)

    measure_annotations =
      measures
      |> Enum.into(%{}, fn measure ->
        {measure,
         %{
           "title" => humanize_member(measure),
           "shortTitle" => short_title(measure),
           "type" => "number"
         }}
      end)

    time_dimension_annotations =
      time_dimensions
      |> Enum.into(%{}, fn
        %{"dimension" => dim} ->
          {dim,
           %{
             "title" => humanize_member(dim),
             "shortTitle" => short_title(dim),
             "type" => "time"
           }}

        dim when is_binary(dim) ->
          {dim,
           %{
             "title" => humanize_member(dim),
             "shortTitle" => short_title(dim),
             "type" => "time"
           }}

        _ ->
          nil
      end)
      |> Enum.filter(&(&1 != nil))
      |> Enum.into(%{})

    %{
      "dimensions" => Map.merge(dimension_annotations, time_dimension_annotations),
      "measures" => measure_annotations,
      "timeDimensions" => time_dimension_annotations
    }
  end

  defp humanize_member(member) do
    member
    |> String.split(".")
    |> List.last()
    |> String.replace("_", " ")
    |> String.split(" ")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  defp short_title(member) do
    member
    |> String.split(".")
    |> List.last()
    |> String.replace("_", " ")
    |> String.split(" ")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end
end
