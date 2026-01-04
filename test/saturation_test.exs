defmodule SaturationTest do
  @moduledoc """
  Saturation tests for HTTP and ADBC connections to Cube.

  Run with:
    mix test test/saturation_test.exs --include live_cube
    mix test test/saturation_test.exs --include saturation
    mix test test/saturation_test.exs --include saturation_1000
  """
  use ExUnit.Case, async: false

  alias PowerOfThree.CubeHttpClient
  alias Adbc.{Connection, Result}
  alias Explorer.Series

  @moduletag :live_cube
  @moduletag timeout: 300_000

  # Cube HTTP API
  @cube_http_url "http://localhost:4008"

  # Cube ADBC (Arrow Native)
  @cube_adbc_port 8120

  setup_all do
    # Check HTTP API
    case :gen_tcp.connect(~c"localhost", 4008, [:binary], 1000) do
      {:ok, socket} ->
        :gen_tcp.close(socket)

      {:error, _} ->
        raise """
        Cube HTTP API is not running on localhost:4008.

        Start with:
          cd ~/projects/learn_erl/cube/examples/recipes/arrow-ipc
          CUBEJS_DB_QUERY_TIMEOUT=45m ./start-cube-api.sh
        """
    end

    # Check ADBC server
    case :gen_tcp.connect(~c"localhost", @cube_adbc_port, [:binary], 1000) do
      {:ok, socket} ->
        :gen_tcp.close(socket)

      {:error, _} ->
        raise """
        Cube ADBC server (cubesqld) is not running on localhost:#{@cube_adbc_port}.

        Start with:
          cd ~/projects/learn_erl/cube/examples/recipes/arrow-ipc
          ./start-cubesqld.sh
        """
    end

    :ok
  end

  # ===========================================================================
  # HTTP Saturation Tests
  # ===========================================================================

  describe "HTTP saturation" do
    @describetag :saturation

    setup do
      {:ok, client} = CubeHttpClient.new(base_url: @cube_http_url)
      {:ok, client: client}
    end

    @tag :saturation
    test "100 concurrent HTTP queries", %{client: client} do
      run_http_saturation(client, 100, "HTTP 100")
    end

    @tag :saturation_1000
    test "1000 concurrent HTTP queries", %{client: client} do
      run_http_saturation(client, 1000, "HTTP 1000")
    end
  end

  # ===========================================================================
  # ADBC Saturation Tests
  # ===========================================================================

  describe "ADBC saturation" do
    @describetag :saturation

    @tag :saturation
    test "100 concurrent ADBC queries" do
      run_adbc_saturation(100, "ADBC 100")
    end

    @tag :saturation_1000
    test "1000 concurrent ADBC queries" do
      run_adbc_saturation(1000, "ADBC 1000")
    end
  end

  # ===========================================================================
  # Comparison Tests
  # ===========================================================================

  describe "HTTP vs ADBC comparison" do
    @describetag :saturation

    setup do
      {:ok, client} = CubeHttpClient.new(base_url: @cube_http_url)
      {:ok, client: client}
    end

    @tag :saturation
    test "compare 100 concurrent queries (with pre-agg)", %{client: client} do
      IO.puts("\n" <> String.duplicate("=", 60))
      IO.puts("COMPARISON: 100 Concurrent Queries (WITH Pre-Aggregation)")
      IO.puts(String.duplicate("=", 60))

      http_metrics = run_http_saturation(client, 100, "HTTP", quiet: true)
      adbc_metrics = run_adbc_saturation(100, "ADBC", quiet: true)

      print_comparison(http_metrics, adbc_metrics)
    end
  end

  # ===========================================================================
  # Pre-Aggregation vs No Pre-Aggregation Tests
  # ===========================================================================

  describe "Pre-Agg vs No Pre-Agg comparison" do
    @describetag :saturation

    setup do
      {:ok, client} = CubeHttpClient.new(base_url: @cube_http_url)
      {:ok, client: client}
    end

    @tag :saturation
    test "ADBC: compare pre-agg vs no pre-agg (50 queries)" do
      IO.puts("\n" <> String.duplicate("=", 60))
      IO.puts("ADBC: Pre-Aggregation vs No Pre-Aggregation (50 queries)")
      IO.puts(String.duplicate("=", 60))

      preagg_metrics = run_adbc_saturation_with_query(50, "With Pre-Agg", cube_query_sql(), quiet: true)
      no_preagg_metrics = run_adbc_saturation_with_query(50, "No Pre-Agg", cube_query_no_preagg_sql(), quiet: true)

      print_preagg_comparison(preagg_metrics, no_preagg_metrics)
    end

    @tag :saturation
    test "HTTP: compare pre-agg vs no pre-agg (50 queries)", %{client: client} do
      IO.puts("\n" <> String.duplicate("=", 60))
      IO.puts("HTTP: Pre-Aggregation vs No Pre-Aggregation (50 queries)")
      IO.puts(String.duplicate("=", 60))

      preagg_metrics = run_http_saturation_with_query(client, 50, "With Pre-Agg", cube_query_http(), quiet: true)
      no_preagg_metrics = run_http_saturation_with_query(client, 50, "No Pre-Agg", cube_query_no_preagg_http(), quiet: true)

      print_preagg_comparison(preagg_metrics, no_preagg_metrics)
    end
  end

  # ===========================================================================
  # Query Definitions
  # ===========================================================================

  # Uses orders_with_preagg cube (has pre-aggregations)
  defp cube_query_http do
    %{
      "dimensions" => ["orders_with_preagg.brand_code"],
      "measures" => ["orders_with_preagg.count", "orders_with_preagg.total_amount_sum"],
      "limit" => 50
    }
  end

  defp cube_query_sql do
    """
    SELECT orders_with_preagg.brand_code,
           MEASURE(orders_with_preagg.count),
           MEASURE(orders_with_preagg.total_amount_sum)
    FROM orders_with_preagg
    GROUP BY 1
    LIMIT 50
    """
  end

  # Uses orders_no_preagg cube (no pre-aggregations - hits DB directly)
  defp cube_query_no_preagg_http do
    %{
      "dimensions" => ["orders_no_preagg.brand_code"],
      "measures" => ["orders_no_preagg.count", "orders_no_preagg.total_amount_sum"],
      "limit" => 50
    }
  end

  defp cube_query_no_preagg_sql do
    """
    SELECT orders_no_preagg.brand_code,
           MEASURE(orders_no_preagg.count),
           MEASURE(orders_no_preagg.total_amount_sum)
    FROM orders_no_preagg
    GROUP BY 1
    LIMIT 50
    """
  end

  # ===========================================================================
  # HTTP Implementation
  # ===========================================================================

  defp run_http_saturation(client, count, label, opts \\ []) do
    run_http_saturation_with_query(client, count, label, cube_query_http(), opts)
  end

  defp run_http_saturation_with_query(client, count, label, query, opts \\ []) do
    quiet = Keyword.get(opts, :quiet, false)

    unless quiet do
      IO.puts("\n" <> String.duplicate("=", 60))
      IO.puts("#{label}: #{count} Concurrent Queries")
      IO.puts(String.duplicate("=", 60))
    end

    start_time = System.monotonic_time(:millisecond)

    tasks =
      for _ <- 1..count do
        Task.async(fn ->
          query_start = System.monotonic_time(:millisecond)

          result =
            try do
              CubeHttpClient.query(client, query,
                max_wait: 120_000,
                poll_interval: 500
              )
            rescue
              e in RuntimeError -> {:error, %{message: Exception.message(e)}}
              e -> {:error, %{message: inspect(e)}}
            end

          query_end = System.monotonic_time(:millisecond)
          latency = query_end - query_start

          case result do
            {:ok, _df} -> {:ok, latency}
            {:error, e} -> {:error, e.message, latency}
          end
        end)
      end

    results = Task.await_many(tasks, 180_000)
    end_time = System.monotonic_time(:millisecond)
    total_duration = end_time - start_time

    metrics = calculate_metrics(results, total_duration, count)
    unless quiet, do: print_metrics(metrics, label)
    metrics
  end

  # ===========================================================================
  # ADBC Implementation
  # ===========================================================================

  defp run_adbc_saturation(count, label, opts \\ []) do
    run_adbc_saturation_with_query(count, label, cube_query_sql(), opts)
  end

  defp run_adbc_saturation_with_query(count, label, query, opts \\ []) do
    quiet = Keyword.get(opts, :quiet, false)
    pool_size = Adbc.CubePool.get_pool_size()

    unless quiet do
      IO.puts("\n" <> String.duplicate("=", 60))
      IO.puts("#{label}: #{count} Concurrent Queries (pool: #{pool_size})")
      IO.puts(String.duplicate("=", 60))
    end

    start_time = System.monotonic_time(:millisecond)

    tasks =
      for _ <- 1..count do
        Task.async(fn ->
          conn = Adbc.CubePool.get_connection()
          query_start = System.monotonic_time(:millisecond)

          result = Connection.query(conn, query)

          query_end = System.monotonic_time(:millisecond)
          latency = query_end - query_start

          case result do
            {:ok, res} ->
              _materialized = Result.materialize(res)
              {:ok, latency}

            {:error, e} ->
              {:error, Exception.message(e), latency}
          end
        end)
      end

    results = Task.await_many(tasks, 180_000)
    end_time = System.monotonic_time(:millisecond)
    total_duration = end_time - start_time

    metrics = calculate_metrics(results, total_duration, count)
    unless quiet, do: print_metrics(metrics, label)
    metrics
  end

  # ===========================================================================
  # Metrics Calculation (using Explorer for statistics)
  # ===========================================================================

  defp calculate_metrics(results, total_duration, count) do
    {successes, failures} =
      Enum.split_with(results, fn
        {:ok, _} -> true
        _ -> false
      end)

    latencies =
      successes
      |> Enum.map(fn {:ok, latency} -> latency end)

    success_count = length(successes)
    failure_count = length(failures)

    # Use Explorer Series for statistics
    stats = if latencies != [] do
      series = Series.from_list(latencies)

      %{
        avg_latency: Series.mean(series),
        min_latency: Series.min(series),
        max_latency: Series.max(series),
        std_dev: Series.standard_deviation(series),
        p50: Series.quantile(series, 0.50),
        p95: Series.quantile(series, 0.95),
        p99: Series.quantile(series, 0.99),
        variance: Series.variance(series)
      }
    else
      %{
        avg_latency: 0,
        min_latency: 0,
        max_latency: 0,
        std_dev: 0,
        p50: 0,
        p95: 0,
        p99: 0,
        variance: 0
      }
    end

    Map.merge(stats, %{
      total: count,
      successes: success_count,
      failures: failure_count,
      success_rate: success_count / count * 100,
      total_duration_ms: total_duration,
      throughput: count / (total_duration / 1000),
      errors: Enum.take(failures, 3)
    })
  end

  # ===========================================================================
  # Output Formatting
  # ===========================================================================

  defp print_metrics(metrics, label) do
    IO.puts("""

    #{label} Results:
      Total queries:     #{metrics.total}
      Successes:         #{metrics.successes}
      Failures:          #{metrics.failures}
      Success rate:      #{round_num(metrics.success_rate)}%

    Latency (milliseconds) - Explorer Statistics:
      Average:           #{round_num(metrics.avg_latency)}ms
      Std Dev:           #{round_num(metrics.std_dev)}ms
      Min:               #{metrics.min_latency}ms
      Max:               #{metrics.max_latency}ms
      P50 (median):      #{round_num(metrics.p50)}ms
      P95:               #{round_num(metrics.p95)}ms
      P99:               #{round_num(metrics.p99)}ms

    Performance:
      Total duration:    #{round_num(metrics.total_duration_ms / 1000)}s
      Throughput:        #{round_num(metrics.throughput)} qps
    """)

    if metrics.failures > 0 do
      IO.puts("  Sample errors:")

      for {:error, msg, _latency} <- metrics.errors do
        IO.puts("    - #{String.slice(msg, 0, 80)}")
      end
    end
  end

  defp round_num(value) when is_float(value), do: Float.round(value, 2)
  defp round_num(value) when is_integer(value), do: value

  defp print_preagg_comparison(preagg_metrics, no_preagg_metrics) do
    IO.puts("""

    +----------------------+----------------+----------------+
    | Metric               | With Pre-Agg   | No Pre-Agg     |
    +----------------------+----------------+----------------+
    | Success Rate         | #{pad(preagg_metrics.success_rate, "%")} | #{pad(no_preagg_metrics.success_rate, "%")} |
    | Throughput (qps)     | #{pad(preagg_metrics.throughput, "")} | #{pad(no_preagg_metrics.throughput, "")} |
    | Avg Latency (ms)     | #{pad(preagg_metrics.avg_latency, "")} | #{pad(no_preagg_metrics.avg_latency, "")} |
    | P50 Latency (ms)     | #{pad(preagg_metrics.p50, "")} | #{pad(no_preagg_metrics.p50, "")} |
    | P95 Latency (ms)     | #{pad(preagg_metrics.p95, "")} | #{pad(no_preagg_metrics.p95, "")} |
    | P99 Latency (ms)     | #{pad(preagg_metrics.p99, "")} | #{pad(no_preagg_metrics.p99, "")} |
    +----------------------+----------------+----------------+
    """)

    speedup = if no_preagg_metrics.avg_latency > 0 do
      no_preagg_metrics.avg_latency / max(preagg_metrics.avg_latency, 1)
    else
      0
    end

    IO.puts("  Pre-Aggregation Speedup: #{round_num(speedup)}x faster")
  end

  defp print_comparison(http_metrics, adbc_metrics) do
    IO.puts("""

    +----------------------+----------------+----------------+
    | Metric               | HTTP           | ADBC           |
    +----------------------+----------------+----------------+
    | Success Rate         | #{pad(http_metrics.success_rate, "%")} | #{pad(adbc_metrics.success_rate, "%")} |
    | Throughput (qps)     | #{pad(http_metrics.throughput, "")} | #{pad(adbc_metrics.throughput, "")} |
    | Avg Latency (ms)     | #{pad(http_metrics.avg_latency, "")} | #{pad(adbc_metrics.avg_latency, "")} |
    | P50 Latency (ms)     | #{pad(http_metrics.p50, "")} | #{pad(adbc_metrics.p50, "")} |
    | P95 Latency (ms)     | #{pad(http_metrics.p95, "")} | #{pad(adbc_metrics.p95, "")} |
    | P99 Latency (ms)     | #{pad(http_metrics.p99, "")} | #{pad(adbc_metrics.p99, "")} |
    +----------------------+----------------+----------------+
    """)

    # Determine winner
    http_score = 0
    adbc_score = 0

    http_score = if http_metrics.throughput > adbc_metrics.throughput, do: http_score + 1, else: http_score
    adbc_score = if adbc_metrics.throughput > http_metrics.throughput, do: adbc_score + 1, else: adbc_score

    http_score = if http_metrics.p95 < adbc_metrics.p95, do: http_score + 1, else: http_score
    adbc_score = if adbc_metrics.p95 < http_metrics.p95, do: adbc_score + 1, else: adbc_score

    winner = cond do
      http_score > adbc_score -> "HTTP"
      adbc_score > http_score -> "ADBC"
      true -> "TIE"
    end

    IO.puts("  Winner: #{winner}")
  end

  defp pad(value, suffix) when is_float(value) do
    str = "#{Float.round(value, 2)}#{suffix}"
    String.pad_leading(str, 14)
  end

  defp pad(value, suffix) when is_integer(value) do
    str = "#{value}#{suffix}"
    String.pad_leading(str, 14)
  end

  defp pad(value, suffix) do
    str = "#{value}#{suffix}"
    String.pad_leading(str, 14)
  end
end
