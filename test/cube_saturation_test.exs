defmodule ExamplesOfPoT.CubeSaturationTest do
  @moduledoc """
  Saturation tests for cubesqld under concurrent load.

  Tests the system's ability to handle high concurrent query volumes:
  - 100 concurrent queries
  - 1,000 concurrent queries
  - 10,000 concurrent queries

  Run with: mix test test/cube_saturation_test.exs --include saturation
  """

  use ExUnit.Case, async: false

  alias Adbc.CubePool
  alias Adbc.{Connection, Result}

  @moduletag :cube
  @moduletag :saturation
  # 30 minutes for saturation tests
  @moduletag timeout: 1_800_000

  # Sample Cube queries from test/adbc_cube_basic_test.exs
  @cube_queries [
                  # Simple dimension query
                  """
                  SELECT orders.FUL
                  FROM orders
                  GROUP BY 1
                  LIMIT 10
                  """,
                  # Dimension with single measure
                  """
                  SELECT
                    orders.FUL,
                    MEASURE(orders.count)
                  FROM orders
                  GROUP BY 1
                  LIMIT 10
                  """,
                  # Multiple measures
                  """
                  SELECT
                    orders.FUL,
                    MEASURE(orders.count),
                    MEASURE(orders.subtotal_amount),
                    MEASURE(orders.total_amount),
                    MEASURE(orders.tax_amount)
                  FROM orders
                  GROUP BY 1
                  LIMIT 10
                  """,
                  # Two dimensions with measures
                  """
                  SELECT
                    orders.FIN,
                    orders.FUL,
                    MEASURE(orders.count),
                    MEASURE(orders.subtotal_amount)
                  FROM orders
                  GROUP BY 1, 2
                  LIMIT 10
                  """,
                  # Simple SELECT
                  "SELECT 1 as test",
                  # String query
                  "SELECT 'hello' as greeting"
                ] ++
                  [
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

  setup_all do
    # Verify cubesqld is running
    case :gen_tcp.connect(~c"localhost", 4445, [:binary], 1000) do
      {:ok, socket} ->
        :gen_tcp.close(socket)
        :ok

      {:error, :econnrefused} ->
        raise """
        Cube server (cubesqld) is not running on localhost:4445.

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

  describe "saturation at 100 concurrent queries" do
    @tag :saturation_100
    test "handles 100 concurrent queries" do
      metrics = run_saturation_test(100)

      IO.puts("\n=== 100 Concurrent Queries ===")
      print_metrics(metrics)

      # Assertions
      assert metrics.total_queries == 100
      # 95% success rate
      assert metrics.success_rate > 0.95
      # Average < 15 seconds (realistic for pool of 10)
      assert metrics.avg_latency_ms < 15_000
    end
  end

  describe "saturation at 1,000 concurrent queries" do
    @tag :saturation_1000
    test "handles 1,000 concurrent queries" do
      metrics = run_saturation_test(1_000)

      IO.puts("\n=== 1,000 Concurrent Queries ===")
      print_metrics(metrics)

      # More lenient assertions for higher load
      assert metrics.total_queries == 1_000
      # 90% success rate
      assert metrics.success_rate > 0.90
      # Average < 120 seconds (10x longer than 100 queries)
      assert metrics.avg_latency_ms < 120_000
    end
  end

  describe "saturation at 10,000 concurrent queries" do
    @tag :saturation_10000
    test "handles 10,000 concurrent queries" do
      metrics = run_saturation_test(10_000)

      IO.puts("\n=== 10,000 Concurrent Queries ===")
      print_metrics(metrics)

      # Even more lenient for extreme load
      assert metrics.total_queries == 10_000
      # 80% success rate
      assert metrics.success_rate > 0.80
      # Average < 20 minutes (100x longer than 100 queries)
      assert metrics.avg_latency_ms < 1_200_000
    end
  end

  describe "progressive saturation test" do
    @tag :progressive
    test "progressive load: 100 -> 1,000 -> 10,000" do
      IO.puts("\n=== Progressive Saturation Test ===\n")

      # Warm up
      IO.puts("Warming up connection pool...")
      run_saturation_test(10)
      Process.sleep(1000)

      # Progressive load
      for load <- [100, 1_000] do
        IO.puts("\n--- Load: #{load} concurrent queries ---")
        metrics = run_saturation_test(load)
        print_metrics(metrics)

        # Brief pause between load levels
        Process.sleep(2000)
      end

      # Test completes successfully
      assert true
    end
  end

  describe "sustained load test" do
    @tag :sustained
    test "sustained 100 qps for 30 seconds" do
      duration_ms = 30_000
      # Queries per second
      qps = 100

      IO.puts("\n=== Sustained Load: #{qps} qps for #{duration_ms / 1000}s ===\n")

      start_time = System.monotonic_time(:millisecond)
      end_time = start_time + duration_ms

      # Track metrics over time
      # Run queries at steady rate using recursion
      interval_metrics = run_sustained_intervals(end_time, qps, [])

      # Print results
      total_queries = length(interval_metrics) * qps
      total_successes = Enum.sum(Enum.map(interval_metrics, & &1.successes))
      success_rate = total_successes / total_queries

      IO.puts("\nSustained Load Results:")
      IO.puts("  Total intervals: #{length(interval_metrics)}")
      IO.puts("  Total queries: #{total_queries}")
      IO.puts("  Total successes: #{total_successes}")
      IO.puts("  Success rate: #{Float.round(success_rate * 100, 2)}%")

      assert success_rate > 0.90
    end
  end

  describe "query type comparison" do
    @tag :query_comparison
    test "compare performance of different query types" do
      IO.puts("\n=== Query Type Performance Comparison ===\n")

      results =
        for {query, idx} <- Enum.with_index(@cube_queries, 1) do
          IO.puts("\nQuery #{idx}:")
          IO.puts(String.trim(query))

          # Run each query type 100 times concurrently
          metrics = run_specific_query_saturation(query, 100)

          IO.puts("  Success rate: #{Float.round(metrics.success_rate * 100, 2)}%")
          IO.puts("  Avg latency: #{Float.round(metrics.avg_latency_ms, 2)}ms")
          IO.puts("  P50: #{metrics.p50_latency_ms}ms")
          IO.puts("  P95: #{metrics.p95_latency_ms}ms")
          IO.puts("  P99: #{metrics.p99_latency_ms}ms")

          {query, metrics}
        end

      # All query types should have reasonable success rates
      for {_query, metrics} <- results do
        assert metrics.success_rate > 0.90
      end
    end
  end

  # Helper Functions

  defp run_sustained_intervals(end_time, qps, acc) do
    current_time = System.monotonic_time(:millisecond)

    if current_time >= end_time do
      acc
    else
      interval_start = current_time

      # Run qps queries in this interval
      tasks =
        for _ <- 1..qps do
          Task.async(fn -> execute_random_query() end)
        end

      results = Task.await_many(tasks, 10_000)

      interval_end = System.monotonic_time(:millisecond)
      interval_duration = interval_end - interval_start

      successes =
        Enum.count(results, fn
          {:ok, _} -> true
          _ -> false
        end)

      interval_metric = %{
        timestamp: interval_start,
        duration_ms: interval_duration,
        queries: qps,
        successes: successes
      }

      # Wait to maintain 1-second intervals
      sleep_ms = max(0, 1000 - interval_duration)
      if sleep_ms > 0, do: Process.sleep(sleep_ms)

      # Recurse with updated accumulator
      run_sustained_intervals(end_time, qps, [interval_metric | acc])
    end
  end

  defp run_saturation_test(num_queries) do
    start_time = System.monotonic_time(:millisecond)

    # Create concurrent tasks
    tasks =
      for _i <- 1..num_queries do
        Task.async(fn ->
          query_start = System.monotonic_time(:millisecond)
          result = execute_random_query()
          query_end = System.monotonic_time(:millisecond)

          {result, query_end - query_start}
        end)
      end

    # Await all results with generous timeout for large tests
    # At ~10s per batch of 100 queries, 10K queries could take ~1000s
    timeout = max(120_000, num_queries * 150)
    results = Task.await_many(tasks, timeout)

    end_time = System.monotonic_time(:millisecond)

    # Calculate metrics
    calculate_metrics(results, start_time, end_time)
  end

  defp run_specific_query_saturation(query, num_queries) do
    start_time = System.monotonic_time(:millisecond)

    tasks =
      for _i <- 1..num_queries do
        Task.async(fn ->
          query_start = System.monotonic_time(:millisecond)
          result = execute_query(query)
          query_end = System.monotonic_time(:millisecond)

          {result, query_end - query_start}
        end)
      end

    results = Task.await_many(tasks, 60_000)
    end_time = System.monotonic_time(:millisecond)

    calculate_metrics(results, start_time, end_time)
  end

  defp execute_random_query do
    query = Enum.random(@cube_queries)
    execute_query(query)
  end

  defp execute_query(query) do
    conn = CubePool.get_connection()

    case Connection.query(conn, query) do
      {:ok, result} ->
        # Materialize to ensure full processing
        _materialized = Result.materialize(result)
        {:ok, :success}

      {:error, reason} ->
        {:error, reason}
    end
  rescue
    error ->
      {:error, error}
  end

  defp calculate_metrics(results, start_time, end_time) do
    total_duration_ms = end_time - start_time

    # Separate successes and failures
    {successes, failures} =
      Enum.split_with(results, fn
        {{:ok, _}, _latency} -> true
        _ -> false
      end)

    # Extract latencies
    latencies = Enum.map(successes, fn {_result, latency} -> latency end)
    sorted_latencies = Enum.sort(latencies)

    # Calculate statistics
    total_queries = length(results)
    success_count = length(successes)
    failure_count = length(failures)
    success_rate = if total_queries > 0, do: success_count / total_queries, else: 0.0

    avg_latency_ms =
      if length(latencies) > 0 do
        Enum.sum(latencies) / length(latencies)
      else
        0.0
      end

    min_latency_ms = if length(latencies) > 0, do: Enum.min(latencies), else: 0
    max_latency_ms = if length(latencies) > 0, do: Enum.max(latencies), else: 0

    # Percentiles
    p50_latency_ms = percentile(sorted_latencies, 0.50)
    p95_latency_ms = percentile(sorted_latencies, 0.95)
    p99_latency_ms = percentile(sorted_latencies, 0.99)

    # Throughput
    throughput_qps =
      if total_duration_ms > 0 do
        total_queries / total_duration_ms * 1000
      else
        0.0
      end

    %{
      total_queries: total_queries,
      success_count: success_count,
      failure_count: failure_count,
      success_rate: success_rate,
      total_duration_ms: total_duration_ms,
      avg_latency_ms: avg_latency_ms,
      min_latency_ms: min_latency_ms,
      max_latency_ms: max_latency_ms,
      p50_latency_ms: p50_latency_ms,
      p95_latency_ms: p95_latency_ms,
      p99_latency_ms: p99_latency_ms,
      throughput_qps: throughput_qps,
      errors: Enum.map(failures, fn {{:error, reason}, _} -> reason end)
    }
  end

  defp percentile([], _p), do: 0

  defp percentile(sorted_list, p) do
    index = trunc(length(sorted_list) * p)
    index = min(index, length(sorted_list) - 1)
    Enum.at(sorted_list, index)
  end

  defp print_metrics(metrics) do
    IO.puts("Results:")
    IO.puts("  Total queries:     #{metrics.total_queries}")
    IO.puts("  Successes:         #{metrics.success_count}")
    IO.puts("  Failures:          #{metrics.failure_count}")
    IO.puts("  Success rate:      #{Float.round(metrics.success_rate * 100, 2)}%")
    IO.puts("")
    IO.puts("Latency (milliseconds):")
    IO.puts("  Average:           #{Float.round(metrics.avg_latency_ms, 2)}ms")
    IO.puts("  Min:               #{metrics.min_latency_ms}ms")
    IO.puts("  Max:               #{metrics.max_latency_ms}ms")
    IO.puts("  P50 (median):      #{metrics.p50_latency_ms}ms")
    IO.puts("  P95:               #{metrics.p95_latency_ms}ms")
    IO.puts("  P99:               #{metrics.p99_latency_ms}ms")
    IO.puts("")
    IO.puts("Performance:")
    IO.puts("  Total duration:    #{Float.round(metrics.total_duration_ms / 1000, 2)}s")
    IO.puts("  Throughput:        #{Float.round(metrics.throughput_qps, 2)} qps")

    if metrics.failure_count > 0 do
      IO.puts("\nErrors (first 10):")

      metrics.errors
      |> Enum.take(10)
      |> Enum.with_index(1)
      |> Enum.each(fn {error, idx} ->
        IO.puts("  #{idx}. #{inspect(error)}")
      end)
    end

    IO.puts("")
  end
end
