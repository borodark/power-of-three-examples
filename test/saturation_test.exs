defmodule SaturationTest do
  @moduledoc """
  Saturation tests for HTTP, ADBC, and Phoenix endpoint connections to Cube.

  ## Three-Way Comparison: Cube HTTP vs ADBC Direct vs Phoenix/ADBC

  | Protocol      | Throughput (qps) | Avg Latency | Architecture              |
  |---------------|------------------|-------------|---------------------------|
  | Cube HTTP     | ~0.08 qps        | ~12,000ms   | HTTP REST + JSON          |
  | ADBC Direct   | ~3,500 qps       | <1ms        | Arrow binary protocol     |
  | Phoenix/ADBC  | ~500-1000 qps    | ~5-10ms     | HTTP + ADBC + Columnar JSON |

  ### Phoenix Endpoint Benefits

  The Phoenix `/cubejs-api/v1/load` endpoint provides:
  - **Drop-in Cube.js compatibility**: Same query format as Cube HTTP API
  - **ADBC-powered backend**: Leverages Arrow native protocol internally
  - **Columnar JSON response**: Efficient wire format aligned with Arrow model
  - **Connection pooling**: Reuses ADBC connections across requests

  ### Why ADBC Throughput Matters

  1. **Sub-millisecond Latency**: ADBC queries complete in <1ms avg
  2. **Massive Parallelism**: 800+ concurrent connections with 100% success rate
  3. **Zero Serialization Overhead**: Arrow columnar format eliminates JSON parsing
  4. **Connection Pooling**: Efficient connection reuse via ADBC connection pools
  5. **Native Binary Protocol**: No HTTP overhead, direct Arrow IPC streaming

  ### Real-World Impact

  - **Interactive Dashboards**: Sub-second refresh rates enable real-time analytics
  - **High-Concurrency**: Support thousands of simultaneous users
  - **Cost Efficiency**: Orders of magnitude fewer compute resources needed
  - **Scalability**: Linear scaling with connection pool size

  ## Run Tests

      # All saturation tests (requires Cube HTTP, ADBC, and Phoenix servers)
      mix test test/saturation_test.exs --include saturation

      # Three-way comparison
      mix test test/saturation_test.exs --include saturation --only "compare 100"

      # Endurance tests (15+ minutes)
      mix test test/saturation_test.exs --include endurance

      # Quick endurance (5 minutes)
      mix test test/saturation_test.exs --include endurance_quick
  """
  use ExUnit.Case, async: true

  alias PowerOfThree.CubeHttpClient
  alias Adbc.{Connection, Result}
  alias Explorer.Series

  @moduletag :live_cube
  @moduletag timeout: 300_000

  @cube_http_port 4008
  # Cube HTTP API
  @cube_http_url "http://localhost:" <> "#{inspect(@cube_http_port)}"

  # Cube ADBC (Arrow Native)
  @cube_adbc_port 8120

  # Phoenix endpoint (ADBC-backed /cubejs-api/v1/load)
  @phoenix_port 4000
  @phoenix_url "http://localhost:#{@phoenix_port}/cubejs-api/v1/load"

  setup_all do
    # Check HTTP API
    case :gen_tcp.connect(~c"localhost", @cube_http_port, [:binary], 1000) do
      {:ok, socket} ->
        :gen_tcp.close(socket)

      {:error, _} ->
        raise """
        Cube HTTP API is not running on localhost: @cube_http_port

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

    # Check Phoenix endpoint
    case :gen_tcp.connect(~c"localhost", @phoenix_port, [:binary], 1000) do
      {:ok, socket} ->
        :gen_tcp.close(socket)

      {:error, _} ->
        raise """
        Phoenix server is not running on localhost:#{@phoenix_port}.

        Start with:
          mix phx.server
        """
    end

    :ok
  end

  # ===========================================================================
  # HTTP Saturation Tests (using mandata_captate variety)
  # ===========================================================================

  describe "HTTP saturation" do
    @describetag :saturation

    setup do
      {:ok, client} = CubeHttpClient.new(base_url: @cube_http_url)
      {:ok, client: client}
    end

    @tag :saturation
    test "100 concurrent HTTP queries (mandata variety)", %{client: client} do
      run_http_saturation_with_queries(client, 100, "HTTP 100", mandata_captate_query_variations_http())
    end
  end

  # ===========================================================================
  # ADBC Saturation Tests (using mandata_captate variety)
  # ===========================================================================

  describe "ADBC saturation" do
    @describetag :saturation

    @tag :saturation
    test "100 concurrent ADBC queries (mandata variety)" do
      run_adbc_saturation_with_queries(100, "ADBC 100", mandata_captate_query_variations_sql())
    end

    @tag :saturation
    test "2_000 concurrent ADBC queries (mandata variety)" do
      run_adbc_saturation_with_queries(2_000, "ADBC 2_000", mandata_captate_query_variations_sql())
    end
  end

  # ===========================================================================
  # Phoenix Endpoint Saturation Tests (using mandata_captate variety)
  # ===========================================================================

  describe "Phoenix endpoint saturation" do
    @describetag :saturation

    @tag :saturation
    test "100 concurrent Phoenix queries (mandata variety)" do
      run_phoenix_saturation_with_queries(100, "Phoenix 100", mandata_captate_query_variations_phoenix())
    end

    @tag :saturation_1000
    test "1000 concurrent Phoenix queries (mandata variety)" do
      run_phoenix_saturation_with_queries(1000, "Phoenix 1000", mandata_captate_query_variations_phoenix())
    end
  end

  # ===========================================================================
  # Comparison Tests
  # ===========================================================================

  describe "HTTP vs ADBC vs Phoenix comparison" do
    @describetag :saturation

    setup do
      {:ok, client} = CubeHttpClient.new(base_url: @cube_http_url)
      {:ok, client: client}
    end

    @tag :saturation
    test "compare 100 concurrent queries (mandata variety)", %{client: client} do
      IO.puts("\n" <> String.duplicate("=", 70))
      IO.puts("COMPARISON: 100 Concurrent × 20 Query Variations (mandata_captate)")
      IO.puts("Granularities: year, quarter, month, week, day, hour | LIMIT 10k-50k")
      IO.puts(String.duplicate("=", 70))

      http_metrics = run_http_saturation_with_queries(client, 100, "Cube HTTP", mandata_captate_query_variations_http(), quiet: true)
      adbc_metrics = run_adbc_saturation_with_queries(100, "ADBC Direct", mandata_captate_query_variations_sql(), quiet: true)
      phoenix_metrics = run_phoenix_saturation_with_queries(100, "Phoenix/ADBC", mandata_captate_query_variations_phoenix(), quiet: true)

      print_three_way_comparison(http_metrics, adbc_metrics, phoenix_metrics)
    end
  end

  # ===========================================================================
  # Dimension/Measure Variety Tests
  # ===========================================================================

  describe "Dimension/measure variety saturation" do
    @describetag :saturation

    setup do
      {:ok, client} = CubeHttpClient.new(base_url: @cube_http_url)
      {:ok, client: client}
    end

    @tag :saturation
    @tag :saturation_variety
    test "HTTP variety (100 concurrent)", %{client: client} do
      run_http_saturation_with_queries(
        client,
        100,
        "HTTP Variety 100",
        cube_query_variations_http()
      )
    end

    @tag :saturation
    @tag :saturation_variety
    test "ADBC variety (100 concurrent)" do
      run_adbc_saturation_with_queries(
        100,
        "ADBC Variety 100",
        cube_query_variations_sql()
      )
    end
  end

  # ===========================================================================
  # Mandata Captate Variety Tests (with pre-aggregations, high volume)
  # ===========================================================================

  describe "Mandata Captate variety (pre-agg cube, LIMIT > 10k)" do
    @describetag :saturation
    @describetag :mandata

    @tag :saturation
    @tag :mandata
    test "ADBC mandata variety (100 concurrent, 20 query types)" do
      IO.puts("\n" <> String.duplicate("=", 70))
      IO.puts("MANDATA CAPTATE: 100 Concurrent × 20 Query Variations (LIMIT 10k+)")
      IO.puts(String.duplicate("=", 70))

      run_adbc_saturation_with_queries(
        100,
        "ADBC Mandata Variety",
        mandata_captate_query_variations_sql()
      )
    end

    @tag :saturation
    @tag :mandata
    test "Phoenix mandata variety (100 concurrent, 20 query types)" do
      IO.puts("\n" <> String.duplicate("=", 70))
      IO.puts("PHOENIX MANDATA: 100 Concurrent × 20 Query Variations (LIMIT 10k+)")
      IO.puts(String.duplicate("=", 70))

      run_phoenix_saturation_with_queries(
        100,
        "Phoenix Mandata Variety",
        mandata_captate_query_variations_phoenix()
      )
    end

    @tag :saturation
    @tag :mandata
    @tag :mandata_1000
    test "ADBC mandata high volume (1000 concurrent)" do
      IO.puts("\n" <> String.duplicate("=", 70))
      IO.puts("ADBC MANDATA HIGH VOLUME: 1000 Concurrent Queries")
      IO.puts(String.duplicate("=", 70))

      run_adbc_saturation_with_queries(
        1000,
        "ADBC Mandata 1000",
        mandata_captate_query_variations_sql()
      )
    end

    @tag :saturation
    @tag :mandata
    test "Three-way mandata comparison (100 concurrent)", %{} do
      IO.puts("\n" <> String.duplicate("=", 70))
      IO.puts("MANDATA CAPTATE: Three-Way Comparison (100 Concurrent)")
      IO.puts(String.duplicate("=", 70))

      adbc_metrics = run_adbc_saturation_with_queries(
        100,
        "ADBC Mandata",
        mandata_captate_query_variations_sql(),
        quiet: true
      )

      phoenix_metrics = run_phoenix_saturation_with_queries(
        100,
        "Phoenix Mandata",
        mandata_captate_query_variations_phoenix(),
        quiet: true
      )

      # Print comparison
      IO.puts("""

      +----------------------+----------------+----------------+
      | Metric               | ADBC Direct    | Phoenix/ADBC   |
      +----------------------+----------------+----------------+
      | Success Rate         | #{pad(adbc_metrics.success_rate, "%")} | #{pad(phoenix_metrics.success_rate, "%")} |
      | Throughput (qps)     | #{pad(adbc_metrics.throughput, "")} | #{pad(phoenix_metrics.throughput, "")} |
      | Avg Latency (ms)     | #{pad(adbc_metrics.avg_latency, "")} | #{pad(phoenix_metrics.avg_latency, "")} |
      | P50 Latency (ms)     | #{pad(adbc_metrics.p50, "")} | #{pad(phoenix_metrics.p50, "")} |
      | P95 Latency (ms)     | #{pad(adbc_metrics.p95, "")} | #{pad(phoenix_metrics.p95, "")} |
      | P99 Latency (ms)     | #{pad(adbc_metrics.p99, "")} | #{pad(phoenix_metrics.p99, "")} |
      +----------------------+----------------+----------------+

      Query variety: 20 different combinations with LIMIT 10,000-50,000
      Granularities: year, quarter, month, week, day, hour
      """)
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
  # Endurance Tests (2 hour sustained load)
  # ===========================================================================

  # ===========================================================================
  # Endurance Tests (using mandata_captate variety, 20 query types)
  # ===========================================================================

  describe "Endurance tests (mandata_captate variety)" do
    @describetag :endurance

    # 15 minute endurance
    @endurance_duration_ms 15 * 60 * 1000
    # Reporting interval (every 1 minute)
    @report_interval_ms 60 * 1000
    # Minimum concurrent requests
    @min_concurrent 256

    setup do
      {:ok, client} = CubeHttpClient.new(base_url: @cube_http_url)
      {:ok, client: client}
    end

    @tag :endurance
    @tag timeout: @endurance_duration_ms + 300_000
    test "ADBC endurance (#{inspect(@min_concurrent)} concurrent, 20 query types)", _context do
      IO.puts("Query variety: 20 mandata_captate combinations, LIMIT 10k-50k")
      run_endurance_test(:adbc, @min_concurrent, @endurance_duration_ms, "ADBC Endurance")
    end

    @tag :endurance
    @tag timeout: @endurance_duration_ms + 300_000
    test "HTTP endurance (#{inspect(@min_concurrent)} concurrent, 20 query types)", %{client: client} do
      IO.puts("Query variety: 20 mandata_captate combinations, LIMIT 10k-50k")
      run_endurance_test(:http, @min_concurrent, @endurance_duration_ms, "HTTP Endurance", client: client)
    end

    @tag :endurance
    @tag timeout: @endurance_duration_ms + 300_000
    test "Phoenix endurance (#{inspect(@min_concurrent)} concurrent, 20 query types)", _context do
      IO.puts("Query variety: 20 mandata_captate combinations, LIMIT 10k-50k")
      run_endurance_test(:phoenix, @min_concurrent, @endurance_duration_ms, "Phoenix Endurance")
    end

    @tag :endurance_quick
    @tag timeout: 600_000
    test "Quick ADBC endurance (5 min, 100 concurrent, 20 query types)" do
      IO.puts("Query variety: 20 mandata_captate combinations, LIMIT 10k-50k")
      run_endurance_test(:adbc, 100, 5 * 60 * 1000, "ADBC Quick Endurance")
    end

    @tag :endurance_quick
    @tag timeout: 600_000
    test "Quick Phoenix endurance (5 min, 100 concurrent, 20 query types)" do
      IO.puts("Query variety: 20 mandata_captate combinations, LIMIT 10k-50k")
      run_endurance_test(:phoenix, 100, 5 * 60 * 1000, "Phoenix Quick Endurance")
    end

    @tag :endurance_quick
    @tag timeout: 600_000
    test "Quick HTTP endurance (5 min, 50 concurrent, 20 query types)", %{client: client} do
      IO.puts("Query variety: 20 mandata_captate combinations, LIMIT 10k-50k")
      run_endurance_test(:http, 50, 5 * 60 * 1000, "HTTP Quick Endurance", client: client)
    end
  end

  defp run_endurance_test(type, concurrency, duration_ms, label, opts \\ []) do
    IO.puts("\n" <> String.duplicate("=", 70))
    IO.puts("#{label}: #{concurrency} Concurrent for #{div(duration_ms, 60_000)} minutes")
    IO.puts(String.duplicate("=", 70))
    IO.puts("Started at: #{DateTime.utc_now() |> DateTime.to_string()}")
    IO.puts("")

    start_time = System.monotonic_time(:millisecond)

    # Shared state for metrics collection
    metrics_agent = start_metrics_agent()

    # Start the sustained load
    runner_pid = spawn_link(fn ->
      run_sustained_load(type, concurrency, duration_ms, metrics_agent, opts)
    end)

    # Start the reporter
    reporter_pid = spawn_link(fn ->
      run_periodic_reporter(metrics_agent, @report_interval_ms, start_time, duration_ms, label)
    end)

    # Wait for duration
    Process.sleep(duration_ms)

    # Stop and collect final metrics
    Process.exit(runner_pid, :normal)
    Process.exit(reporter_pid, :normal)
    Process.sleep(1000)

    # Final report
    print_final_endurance_report(metrics_agent, label, duration_ms)

    Agent.stop(metrics_agent)
  end

  defp start_metrics_agent do
    {:ok, pid} = Agent.start_link(fn ->
      %{
        total_requests: 0,
        successful_requests: 0,
        failed_requests: 0,
        latencies: [],
        errors: [],
        interval_metrics: []
      }
    end)
    pid
  end

  defp run_sustained_load(type, concurrency, duration_ms, metrics_agent, opts) do
    client = Keyword.get(opts, :client)
    start_time = System.monotonic_time(:millisecond)

    # Create a pool of worker tasks that continuously run queries
    workers = for i <- 1..concurrency do
      Task.async(fn ->
        worker_loop(type, client, metrics_agent, start_time, duration_ms, i)
      end)
    end

    # Wait for all workers (they'll exit when duration is reached)
    Task.await_many(workers, duration_ms + 60_000)
  end

  defp worker_loop(type, client, metrics_agent, start_time, duration_ms, _worker_id) do
    elapsed = System.monotonic_time(:millisecond) - start_time

    if elapsed < duration_ms do
      # Execute query
      {result, latency} = execute_timed_query(type, client)

      # Record metrics
      Agent.update(metrics_agent, fn state ->
        case result do
          :ok ->
            %{state |
              total_requests: state.total_requests + 1,
              successful_requests: state.successful_requests + 1,
              latencies: [latency | Enum.take(state.latencies, 9999)]  # Keep last 10k
            }
          {:error, msg} ->
            %{state |
              total_requests: state.total_requests + 1,
              failed_requests: state.failed_requests + 1,
              errors: [msg | Enum.take(state.errors, 99)]  # Keep last 100 errors
            }
        end
      end)

      # Small delay to prevent CPU saturation
      Process.sleep(10)

      # Continue loop
      worker_loop(type, client, metrics_agent, start_time, duration_ms, _worker_id)
    end
  end

  # Get a random query from mandata_captate variations for variety in endurance tests
  defp get_random_mandata_query_sql do
    queries = mandata_captate_query_variations_sql()
    Enum.at(queries, :rand.uniform(length(queries)) - 1)
  end

  defp get_random_mandata_query_http do
    queries = mandata_captate_query_variations_http()
    Enum.at(queries, :rand.uniform(length(queries)) - 1)
  end

  defp get_random_mandata_query_phoenix do
    queries = mandata_captate_query_variations_phoenix()
    Enum.at(queries, :rand.uniform(length(queries)) - 1)
  end

  defp execute_timed_query(:adbc, _client) do
    conn = Adbc.CubePool.get_connection()
    query = get_random_mandata_query_sql()
    query_start = System.monotonic_time(:millisecond)

    result = try do
      case Connection.query(conn, query) do
        {:ok, res} ->
          _materialized = Result.materialize(res)
          :ok
        {:error, e} ->
          {:error, Exception.message(e)}
      end
    rescue
      e -> {:error, Exception.message(e)}
    end

    latency = System.monotonic_time(:millisecond) - query_start
    {result, latency}
  end

  defp execute_timed_query(:http, client) do
    query = get_random_mandata_query_http()
    query_start = System.monotonic_time(:millisecond)

    result = try do
      case CubeHttpClient.query(client, query, max_wait: 120_000, poll_interval: 500) do
        {:ok, _df} -> :ok
        {:error, e} -> {:error, e.message}
      end
    rescue
      e -> {:error, Exception.message(e)}
    end

    latency = System.monotonic_time(:millisecond) - query_start
    {result, latency}
  end

  defp execute_timed_query(:phoenix, _client) do
    :inets.start()
    query = get_random_mandata_query_phoenix()
    query_start = System.monotonic_time(:millisecond)

    result = try do
      body = Jason.encode!(%{"query" => query})

      case :httpc.request(
             :post,
             {~c"#{@phoenix_url}", [], ~c"application/json", body},
             [timeout: 120_000],
             []
           ) do
        {:ok, {{_, 200, _}, _, _body}} -> :ok
        {:ok, {{_, status, _}, _, body}} -> {:error, "HTTP #{status}: #{body}"}
        {:error, reason} -> {:error, inspect(reason)}
      end
    rescue
      e -> {:error, Exception.message(e)}
    end

    latency = System.monotonic_time(:millisecond) - query_start
    {result, latency}
  end

  defp run_periodic_reporter(metrics_agent, interval_ms, start_time, total_duration_ms, label) do
    Process.sleep(interval_ms)

    elapsed = System.monotonic_time(:millisecond) - start_time

    if elapsed < total_duration_ms do
      state = Agent.get(metrics_agent, & &1)

      # Calculate interval metrics using Explorer
      stats = calculate_explorer_stats(state.latencies)

      elapsed_min = div(elapsed, 60_000)
      remaining_min = div(total_duration_ms - elapsed, 60_000)

      success_rate = if state.total_requests > 0 do
        state.successful_requests / state.total_requests * 100
      else
        0.0
      end

      throughput = if elapsed > 0 do
        state.total_requests / (elapsed / 1000)
      else
        0.0
      end
      last_throughput =
        case state.interval_metrics do
          [{_min, _stats, tput, _rate} | _] -> tput
          _ -> nil
        end

      {throughput_growth, throughput_growth_pct} =
        if is_float(last_throughput) and last_throughput > 0 do
          growth = throughput - last_throughput
          {growth, growth / last_throughput * 100}
        else
          {nil, nil}
        end

      IO.puts("""

      [#{elapsed_min} min elapsed, #{remaining_min} min remaining] #{label}
      ├─ Requests: #{state.total_requests} total (#{state.successful_requests} ok, #{state.failed_requests} failed)
      ├─ Success Rate: #{round_num(success_rate)}%
      ├─ Throughput: #{round_num(throughput)} qps
      ├─ Throughput Growth: #{format_throughput_growth(throughput_growth, throughput_growth_pct)}
      ├─ Latency: avg=#{round_num(stats.avg)}ms, p50=#{round_num(stats.p50)}ms, p95=#{round_num(stats.p95)}ms, p99=#{round_num(stats.p99)}ms
      └─ Std Dev: #{round_num(stats.std_dev)}ms
      """)

      # Store interval snapshot
      Agent.update(metrics_agent, fn s ->
        %{s | interval_metrics: [{elapsed_min, stats, throughput, success_rate} | s.interval_metrics]}
      end)

      run_periodic_reporter(metrics_agent, interval_ms, start_time, total_duration_ms, label)
    end
  end

  defp calculate_explorer_stats([]), do: %{avg: 0, std_dev: 0, min: 0, max: 0, p50: 0, p95: 0, p99: 0}
  defp calculate_explorer_stats(latencies) do
    series = Series.from_list(latencies)

    %{
      avg: Series.mean(series) || 0,
      std_dev: Series.standard_deviation(series) || 0,
      min: Series.min(series) || 0,
      max: Series.max(series) || 0,
      p50: Series.quantile(series, 0.50) || 0,
      p95: Series.quantile(series, 0.95) || 0,
      p99: Series.quantile(series, 0.99) || 0
    }
  end

  defp print_final_endurance_report(metrics_agent, label, duration_ms) do
    state = Agent.get(metrics_agent, & &1)
    stats = calculate_explorer_stats(state.latencies)

    success_rate = if state.total_requests > 0 do
      state.successful_requests / state.total_requests * 100
    else
      0.0
    end

    throughput = state.total_requests / (duration_ms / 1000)
    {first_throughput, last_throughput} =
      case Enum.reverse(state.interval_metrics) do
        [{_min, _stats, first_tput, _rate} | _] = intervals ->
          {_min, _stats, last_tput, _rate} = List.last(intervals)
          {first_tput, last_tput}
        _ ->
          {nil, nil}
      end

    {overall_growth, overall_growth_pct} =
      if is_float(first_throughput) and first_throughput > 0 and is_float(last_throughput) do
        growth = last_throughput - first_throughput
        {growth, growth / first_throughput * 100}
      else
        {nil, nil}
      end

    IO.puts("\n" <> String.duplicate("=", 70))
    IO.puts("FINAL REPORT: #{label}")
    IO.puts(String.duplicate("=", 70))
    IO.puts("Completed at: #{DateTime.utc_now() |> DateTime.to_string()}")
    IO.puts("""

    Summary:
      Duration:          #{div(duration_ms, 60_000)} minutes
      Total Requests:    #{state.total_requests}
      Successful:        #{state.successful_requests}
      Failed:            #{state.failed_requests}
      Success Rate:      #{round_num(success_rate)}%

    ┌──────────────────────────────────────────────────────────────────┐
    │  THROUGHPUT PERFORMANCE                                          │
    ├──────────────────────────────────────────────────────────────────┤
    │  Avg Throughput:    #{String.pad_trailing("#{round_num(throughput)} qps", 45)}│
    │  Throughput Growth: #{String.pad_trailing(format_throughput_growth(overall_growth, overall_growth_pct), 45)}│
    └──────────────────────────────────────────────────────────────────┘

    Latency Statistics (Explorer):
      Average:           #{round_num(stats.avg)}ms
      Std Deviation:     #{round_num(stats.std_dev)}ms
      Min:               #{stats.min}ms
      Max:               #{stats.max}ms
      P50 (median):      #{round_num(stats.p50)}ms
      P95:               #{round_num(stats.p95)}ms
      P99:               #{round_num(stats.p99)}ms
    """)

    if length(state.errors) > 0 do
      IO.puts("  Sample Errors (last 5):")
      state.errors
      |> Enum.take(5)
      |> Enum.each(fn err ->
        IO.puts("    - #{String.slice(to_string(err), 0, 70)}")
      end)
    end

    # Print trend if we have interval data
    if length(state.interval_metrics) > 1 do
      IO.puts("\n  Throughput Trend:")
      state.interval_metrics
      |> Enum.reverse()
      |> Enum.each(fn {min, _stats, tput, rate} ->
        bar = String.duplicate("█", round(tput / 10))
        IO.puts("    #{String.pad_leading("#{min}", 3)}m: #{bar} #{round_num(tput)} qps (#{round_num(rate)}%)")
      end)
    end

    IO.puts(String.duplicate("=", 70))
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

  defp cube_query_variations_http do
    [
      %{
        "dimensions" => ["orders_with_preagg.brand_code"],
        "measures" => ["orders_with_preagg.count"],
        "limit" => 100
      },
      %{
        "dimensions" => ["orders_with_preagg.market_code"],
        "measures" => ["orders_with_preagg.count", "orders_with_preagg.total_amount_sum"],
        "limit" => 200
      },
      %{
        "dimensions" => ["orders_with_preagg.market_code", "orders_with_preagg.brand_code"],
        "measures" => ["orders_with_preagg.count", "orders_with_preagg.tax_amount_sum"],
        "limit" => 500
      },
      %{
        "dimensions" => [
          "orders_with_preagg.market_code",
          "orders_with_preagg.brand_code",
          "orders_with_preagg.financial_status"
        ],
        "measures" => [
          "orders_with_preagg.count",
          "orders_with_preagg.total_amount_sum",
          "orders_with_preagg.tax_amount_sum"
        ],
        "limit" => 1000
      },
      %{
        "dimensions" => ["orders_with_preagg.brand_code"],
        "measures" => [
          "orders_with_preagg.subtotal_amount_sum",
          "orders_with_preagg.total_amount_sum",
          "orders_with_preagg.tax_amount_sum"
        ],
        "limit" => 200
      },
      %{
        "dimensions" => ["orders_with_preagg.brand_code"],
        "measures" => ["orders_with_preagg.count"],
        "timeDimensions" => [
          %{
            "dimension" => "orders_with_preagg.updated_at",
            "granularity" => "day",
            "dateRange" => ["2024-01-01", "2024-12-31"]
          }
        ],
        "limit" => 500
      },
      %{
        "measures" => ["orders_with_preagg.count"],
        "limit" => 1
      }
    ]
  end

  defp cube_query_variations_sql do
    [
      """
      SELECT orders_with_preagg.brand_code,
             MEASURE(orders_with_preagg.count)
      FROM orders_with_preagg
      GROUP BY 1
      LIMIT 100
      """,
      """
      SELECT orders_with_preagg.market_code,
             MEASURE(orders_with_preagg.count),
             MEASURE(orders_with_preagg.total_amount_sum)
      FROM orders_with_preagg
      GROUP BY 1
      LIMIT 200
      """,
      """
      SELECT orders_with_preagg.market_code,
             orders_with_preagg.brand_code,
             MEASURE(orders_with_preagg.count),
             MEASURE(orders_with_preagg.tax_amount_sum)
      FROM orders_with_preagg
      GROUP BY 1, 2
      LIMIT 500
      """,
      """
      SELECT orders_with_preagg.market_code,
             orders_with_preagg.brand_code,
             orders_with_preagg.financial_status,
             MEASURE(orders_with_preagg.count),
             MEASURE(orders_with_preagg.total_amount_sum),
             MEASURE(orders_with_preagg.tax_amount_sum)
      FROM orders_with_preagg
      GROUP BY 1, 2, 3
      LIMIT 1000
      """,
      """
      SELECT orders_with_preagg.brand_code,
             MEASURE(orders_with_preagg.subtotal_amount_sum),
             MEASURE(orders_with_preagg.total_amount_sum),
             MEASURE(orders_with_preagg.tax_amount_sum)
      FROM orders_with_preagg
      GROUP BY 1
      LIMIT 200
      """,
      """
      SELECT orders_with_preagg.brand_code,
             DATE_TRUNC('day', orders_with_preagg.updated_at),
             MEASURE(orders_with_preagg.count)
      FROM orders_with_preagg
      GROUP BY 1, 2
      LIMIT 500
      """,
      """
      SELECT MEASURE(orders_with_preagg.count)
      FROM orders_with_preagg
      LIMIT 1
      """
    ]
  end

  # Phoenix endpoint query (uses orders_with_preagg via ADBC)
  defp phoenix_query do
    %{
      "dimensions" => ["orders_with_preagg.brand_code"],
      "measures" => ["orders_with_preagg.count", "orders_with_preagg.total_amount_sum"],
      "limit" => 50
    }
  end

  # ===========================================================================
  # Mandata Captate Query Variations (20 combinations, LIMIT 10k-50k)
  # ===========================================================================

  # ADBC SQL queries for mandata_captate
  defp mandata_captate_query_variations_sql do
    [
      # 1. Simple yearly aggregation
      """
      SELECT
        DATE_TRUNC('year', mandata_captate.updated_at),
        MEASURE(mandata_captate.count)
      FROM mandata_captate
      GROUP BY 1
      LIMIT 10000
      """,

      # 2. Yearly with multiple measures
      """
      SELECT
        DATE_TRUNC('year', mandata_captate.updated_at),
        MEASURE(mandata_captate.count),
        MEASURE(mandata_captate.total_amount_sum),
        MEASURE(mandata_captate.tax_amount_sum)
      FROM mandata_captate
      GROUP BY 1
      LIMIT 15000
      """,

      # 3. Quarterly by brand
      """
      SELECT
        DATE_TRUNC('quarter', mandata_captate.updated_at),
        mandata_captate.brand_code,
        MEASURE(mandata_captate.count),
        MEASURE(mandata_captate.total_amount_sum)
      FROM mandata_captate
      GROUP BY 1, 2
      LIMIT 20000
      """,

      # 4. Monthly by market and brand
      """
      SELECT
        DATE_TRUNC('month', mandata_captate.updated_at),
        mandata_captate.market_code,
        mandata_captate.brand_code,
        MEASURE(mandata_captate.count)
      FROM mandata_captate
      GROUP BY 1, 2, 3
      LIMIT 25000
      """,

      # 5. Weekly with all amount measures
      """
      SELECT
        DATE_TRUNC('week', mandata_captate.updated_at),
        MEASURE(mandata_captate.total_amount_sum),
        MEASURE(mandata_captate.subtotal_amount_sum),
        MEASURE(mandata_captate.tax_amount_sum),
        MEASURE(mandata_captate.discount_total_amount_sum)
      FROM mandata_captate
      GROUP BY 1
      LIMIT 30000
      """,

      # 6. Daily by financial status
      """
      SELECT
        DATE_TRUNC('day', mandata_captate.updated_at),
        mandata_captate.financial_status,
        MEASURE(mandata_captate.count),
        MEASURE(mandata_captate.total_amount_sum)
      FROM mandata_captate
      GROUP BY 1, 2
      LIMIT 35000
      """,

      # 7. Hourly (high granularity)
      """
      SELECT
        DATE_TRUNC('hour', mandata_captate.updated_at),
        MEASURE(mandata_captate.count)
      FROM mandata_captate
      GROUP BY 1
      LIMIT 50000
      """,

      # 8. Yearly by fulfillment status
      """
      SELECT
        DATE_TRUNC('year', mandata_captate.updated_at),
        mandata_captate.fulfillment_status,
        MEASURE(mandata_captate.count),
        MEASURE(mandata_captate.customer_id_distinct)
      FROM mandata_captate
      GROUP BY 1, 2
      LIMIT 12000
      """,

      # 9. Quarterly with distinct counts
      """
      SELECT
        DATE_TRUNC('quarter', mandata_captate.updated_at),
        MEASURE(mandata_captate.count),
        MEASURE(mandata_captate.customer_id_distinct),
        MEASURE(mandata_captate.total_amount_distinct)
      FROM mandata_captate
      GROUP BY 1
      LIMIT 18000
      """,

      # 10. Monthly by brand with delivery
      """
      SELECT
        DATE_TRUNC('month', mandata_captate.updated_at),
        mandata_captate.brand_code,
        MEASURE(mandata_captate.count),
        MEASURE(mandata_captate.delivery_subtotal_amount_sum)
      FROM mandata_captate
      GROUP BY 1, 2
      LIMIT 22000
      """,

      # 11. Weekly by market, brand, financial status
      """
      SELECT
        DATE_TRUNC('week', mandata_captate.updated_at),
        mandata_captate.market_code,
        mandata_captate.brand_code,
        mandata_captate.financial_status,
        MEASURE(mandata_captate.count)
      FROM mandata_captate
      GROUP BY 1, 2, 3, 4
      LIMIT 40000
      """,

      # 12. Daily comprehensive measures
      """
      SELECT
        DATE_TRUNC('day', mandata_captate.updated_at),
        MEASURE(mandata_captate.count),
        MEASURE(mandata_captate.customer_id_sum),
        MEASURE(mandata_captate.total_amount_sum),
        MEASURE(mandata_captate.subtotal_amount_sum)
      FROM mandata_captate
      GROUP BY 1
      LIMIT 45000
      """,

      # 13. Yearly full dimension breakdown
      """
      SELECT
        DATE_TRUNC('year', mandata_captate.updated_at),
        mandata_captate.market_code,
        mandata_captate.brand_code,
        mandata_captate.fulfillment_status,
        mandata_captate.financial_status,
        MEASURE(mandata_captate.count)
      FROM mandata_captate
      GROUP BY 1, 2, 3, 4, 5
      LIMIT 50000
      """,

      # 14. Quarterly all amounts
      """
      SELECT
        DATE_TRUNC('quarter', mandata_captate.updated_at),
        mandata_captate.brand_code,
        MEASURE(mandata_captate.total_amount_sum),
        MEASURE(mandata_captate.tax_amount_sum),
        MEASURE(mandata_captate.subtotal_amount_sum),
        MEASURE(mandata_captate.discount_total_amount_sum),
        MEASURE(mandata_captate.delivery_subtotal_amount_sum)
      FROM mandata_captate
      GROUP BY 1, 2
      LIMIT 28000
      """,

      # 15. Monthly customer metrics
      """
      SELECT
        DATE_TRUNC('month', mandata_captate.updated_at),
        MEASURE(mandata_captate.count),
        MEASURE(mandata_captate.customer_id_sum),
        MEASURE(mandata_captate.customer_id_distinct)
      FROM mandata_captate
      GROUP BY 1
      LIMIT 15000
      """,

      # 16. Weekly by fulfillment and financial
      """
      SELECT
        DATE_TRUNC('week', mandata_captate.updated_at),
        mandata_captate.fulfillment_status,
        mandata_captate.financial_status,
        MEASURE(mandata_captate.count),
        MEASURE(mandata_captate.total_amount_sum)
      FROM mandata_captate
      GROUP BY 1, 2, 3
      LIMIT 35000
      """,

      # 17. Daily by market only
      """
      SELECT
        DATE_TRUNC('day', mandata_captate.updated_at),
        mandata_captate.market_code,
        MEASURE(mandata_captate.count),
        MEASURE(mandata_captate.total_amount_sum),
        MEASURE(mandata_captate.customer_id_distinct)
      FROM mandata_captate
      GROUP BY 1, 2
      LIMIT 42000
      """,

      # 18. Hourly by brand
      """
      SELECT
        DATE_TRUNC('hour', mandata_captate.updated_at),
        mandata_captate.brand_code,
        MEASURE(mandata_captate.count),
        MEASURE(mandata_captate.total_amount_sum)
      FROM mandata_captate
      GROUP BY 1, 2
      LIMIT 50000
      """,

      # 19. Yearly tax analysis
      """
      SELECT
        DATE_TRUNC('year', mandata_captate.updated_at),
        mandata_captate.market_code,
        MEASURE(mandata_captate.tax_amount_sum),
        MEASURE(mandata_captate.tax_amount_distinct),
        MEASURE(mandata_captate.total_amount_sum)
      FROM mandata_captate
      GROUP BY 1, 2
      LIMIT 20000
      """,

      # 20. Monthly comprehensive with all measures
      """
      SELECT
        DATE_TRUNC('month', mandata_captate.updated_at),
        mandata_captate.brand_code,
        mandata_captate.market_code,
        MEASURE(mandata_captate.count),
        MEASURE(mandata_captate.customer_id_distinct),
        MEASURE(mandata_captate.total_amount_sum),
        MEASURE(mandata_captate.subtotal_amount_sum),
        MEASURE(mandata_captate.tax_amount_sum),
        MEASURE(mandata_captate.discount_total_amount_sum)
      FROM mandata_captate
      GROUP BY 1, 2, 3
      LIMIT 50000
      """
    ]
  end

  # HTTP queries for mandata_captate (same format for Cube HTTP API and Phoenix)
  defp mandata_captate_query_variations_http, do: mandata_captate_query_variations_phoenix()

  # Phoenix/Cube HTTP queries for mandata_captate
  defp mandata_captate_query_variations_phoenix do
    [
      # 1. Simple yearly
      %{
        "measures" => ["mandata_captate.count"],
        "timeDimensions" => [%{"dimension" => "mandata_captate.updated_at", "granularity" => "year"}],
        "limit" => 10000
      },

      # 2. Yearly with multiple measures
      %{
        "measures" => ["mandata_captate.count", "mandata_captate.total_amount_sum", "mandata_captate.tax_amount_sum"],
        "timeDimensions" => [%{"dimension" => "mandata_captate.updated_at", "granularity" => "year"}],
        "limit" => 15000
      },

      # 3. Quarterly by brand
      %{
        "dimensions" => ["mandata_captate.brand_code"],
        "measures" => ["mandata_captate.count", "mandata_captate.total_amount_sum"],
        "timeDimensions" => [%{"dimension" => "mandata_captate.updated_at", "granularity" => "quarter"}],
        "limit" => 20000
      },

      # 4. Monthly by market and brand
      %{
        "dimensions" => ["mandata_captate.market_code", "mandata_captate.brand_code"],
        "measures" => ["mandata_captate.count"],
        "timeDimensions" => [%{"dimension" => "mandata_captate.updated_at", "granularity" => "month"}],
        "limit" => 25000
      },

      # 5. Weekly with all amount measures
      %{
        "measures" => [
          "mandata_captate.total_amount_sum",
          "mandata_captate.subtotal_amount_sum",
          "mandata_captate.tax_amount_sum",
          "mandata_captate.discount_total_amount_sum"
        ],
        "timeDimensions" => [%{"dimension" => "mandata_captate.updated_at", "granularity" => "week"}],
        "limit" => 30000
      },

      # 6. Daily by financial status
      %{
        "dimensions" => ["mandata_captate.financial_status"],
        "measures" => ["mandata_captate.count", "mandata_captate.total_amount_sum"],
        "timeDimensions" => [%{"dimension" => "mandata_captate.updated_at", "granularity" => "day"}],
        "limit" => 35000
      },

      # 7. Hourly
      %{
        "measures" => ["mandata_captate.count"],
        "timeDimensions" => [%{"dimension" => "mandata_captate.updated_at", "granularity" => "hour"}],
        "limit" => 50000
      },

      # 8. Yearly by fulfillment
      %{
        "dimensions" => ["mandata_captate.fulfillment_status"],
        "measures" => ["mandata_captate.count", "mandata_captate.customer_id_distinct"],
        "timeDimensions" => [%{"dimension" => "mandata_captate.updated_at", "granularity" => "year"}],
        "limit" => 12000
      },

      # 9. Quarterly with distinct counts
      %{
        "measures" => ["mandata_captate.count", "mandata_captate.customer_id_distinct", "mandata_captate.total_amount_distinct"],
        "timeDimensions" => [%{"dimension" => "mandata_captate.updated_at", "granularity" => "quarter"}],
        "limit" => 18000
      },

      # 10. Monthly by brand with delivery
      %{
        "dimensions" => ["mandata_captate.brand_code"],
        "measures" => ["mandata_captate.count", "mandata_captate.delivery_subtotal_amount_sum"],
        "timeDimensions" => [%{"dimension" => "mandata_captate.updated_at", "granularity" => "month"}],
        "limit" => 22000
      },

      # 11. Weekly by market, brand, financial status
      %{
        "dimensions" => ["mandata_captate.market_code", "mandata_captate.brand_code", "mandata_captate.financial_status"],
        "measures" => ["mandata_captate.count"],
        "timeDimensions" => [%{"dimension" => "mandata_captate.updated_at", "granularity" => "week"}],
        "limit" => 40000
      },

      # 12. Daily comprehensive measures
      %{
        "measures" => [
          "mandata_captate.count",
          "mandata_captate.customer_id_sum",
          "mandata_captate.total_amount_sum",
          "mandata_captate.subtotal_amount_sum"
        ],
        "timeDimensions" => [%{"dimension" => "mandata_captate.updated_at", "granularity" => "day"}],
        "limit" => 45000
      },

      # 13. Yearly full dimension breakdown
      %{
        "dimensions" => [
          "mandata_captate.market_code",
          "mandata_captate.brand_code",
          "mandata_captate.fulfillment_status",
          "mandata_captate.financial_status"
        ],
        "measures" => ["mandata_captate.count"],
        "timeDimensions" => [%{"dimension" => "mandata_captate.updated_at", "granularity" => "year"}],
        "limit" => 50000
      },

      # 14. Quarterly all amounts
      %{
        "dimensions" => ["mandata_captate.brand_code"],
        "measures" => [
          "mandata_captate.total_amount_sum",
          "mandata_captate.tax_amount_sum",
          "mandata_captate.subtotal_amount_sum",
          "mandata_captate.discount_total_amount_sum",
          "mandata_captate.delivery_subtotal_amount_sum"
        ],
        "timeDimensions" => [%{"dimension" => "mandata_captate.updated_at", "granularity" => "quarter"}],
        "limit" => 28000
      },

      # 15. Monthly customer metrics
      %{
        "measures" => ["mandata_captate.count", "mandata_captate.customer_id_sum", "mandata_captate.customer_id_distinct"],
        "timeDimensions" => [%{"dimension" => "mandata_captate.updated_at", "granularity" => "month"}],
        "limit" => 15000
      },

      # 16. Weekly by fulfillment and financial
      %{
        "dimensions" => ["mandata_captate.fulfillment_status", "mandata_captate.financial_status"],
        "measures" => ["mandata_captate.count", "mandata_captate.total_amount_sum"],
        "timeDimensions" => [%{"dimension" => "mandata_captate.updated_at", "granularity" => "week"}],
        "limit" => 35000
      },

      # 17. Daily by market
      %{
        "dimensions" => ["mandata_captate.market_code"],
        "measures" => ["mandata_captate.count", "mandata_captate.total_amount_sum", "mandata_captate.customer_id_distinct"],
        "timeDimensions" => [%{"dimension" => "mandata_captate.updated_at", "granularity" => "day"}],
        "limit" => 42000
      },

      # 18. Hourly by brand
      %{
        "dimensions" => ["mandata_captate.brand_code"],
        "measures" => ["mandata_captate.count", "mandata_captate.total_amount_sum"],
        "timeDimensions" => [%{"dimension" => "mandata_captate.updated_at", "granularity" => "hour"}],
        "limit" => 50000
      },

      # 19. Yearly tax analysis
      %{
        "dimensions" => ["mandata_captate.market_code"],
        "measures" => ["mandata_captate.tax_amount_sum", "mandata_captate.tax_amount_distinct", "mandata_captate.total_amount_sum"],
        "timeDimensions" => [%{"dimension" => "mandata_captate.updated_at", "granularity" => "year"}],
        "limit" => 20000
      },

      # 20. Monthly comprehensive
      %{
        "dimensions" => ["mandata_captate.brand_code", "mandata_captate.market_code"],
        "measures" => [
          "mandata_captate.count",
          "mandata_captate.customer_id_distinct",
          "mandata_captate.total_amount_sum",
          "mandata_captate.subtotal_amount_sum",
          "mandata_captate.tax_amount_sum",
          "mandata_captate.discount_total_amount_sum"
        ],
        "timeDimensions" => [%{"dimension" => "mandata_captate.updated_at", "granularity" => "month"}],
        "limit" => 50000
      }
    ]
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

  defp run_http_saturation_with_queries(client, count, label, queries, opts \\ []) do
    quiet = Keyword.get(opts, :quiet, false)
    query_count = length(queries)

    unless quiet do
      IO.puts("\n" <> String.duplicate("=", 60))
      IO.puts("#{label}: #{count} Concurrent Queries (#{query_count} variants)")
      IO.puts(String.duplicate("=", 60))
    end

    start_time = System.monotonic_time(:millisecond)

    tasks =
      for idx <- 1..count do
        Task.async(fn ->
          query = Enum.at(queries, rem(idx - 1, query_count))
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

  defp run_adbc_saturation_with_queries(count, label, queries, opts \\ []) do
    quiet = Keyword.get(opts, :quiet, false)
    pool_size = Adbc.CubePool.get_pool_size()
    query_count = length(queries)

    unless quiet do
      IO.puts("\n" <> String.duplicate("=", 60))
      IO.puts("#{label}: #{count} Concurrent Queries (#{query_count} variants, pool: #{pool_size})")
      IO.puts(String.duplicate("=", 60))
    end

    start_time = System.monotonic_time(:millisecond)

    tasks =
      for idx <- 1..count do
        Task.async(fn ->
          query = Enum.at(queries, rem(idx - 1, query_count))
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
              {:error, inspect(e), latency}
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
  # Phoenix Endpoint Implementation
  # ===========================================================================

  defp run_phoenix_saturation(count, label, opts \\ []) do
    quiet = Keyword.get(opts, :quiet, false)

    unless quiet do
      IO.puts("\n" <> String.duplicate("=", 60))
      IO.puts("#{label}: #{count} Concurrent Queries (Phoenix/ADBC)")
      IO.puts(String.duplicate("=", 60))
    end

    # Ensure inets is started for httpc
    :inets.start()

    start_time = System.monotonic_time(:millisecond)

    tasks =
      for _ <- 1..count do
        Task.async(fn ->
          query_start = System.monotonic_time(:millisecond)

          body = Jason.encode!(%{"query" => phoenix_query()})

          result =
            try do
              case :httpc.request(
                     :post,
                     {~c"#{@phoenix_url}", [], ~c"application/json", body},
                     [timeout: 120_000],
                     []
                   ) do
                {:ok, {{_, 200, _}, _, _response_body}} ->
                  :ok

                {:ok, {{_, status, _}, _, response_body}} ->
                  {:error, "HTTP #{status}: #{String.slice(to_string(response_body), 0, 100)}"}

                {:error, reason} ->
                  {:error, inspect(reason)}
              end
            rescue
              e -> {:error, Exception.message(e)}
            end

          query_end = System.monotonic_time(:millisecond)
          latency = query_end - query_start

          case result do
            :ok -> {:ok, latency}
            {:error, msg} -> {:error, msg, latency}
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

  defp run_phoenix_saturation_with_queries(count, label, queries, opts \\ []) do
    quiet = Keyword.get(opts, :quiet, false)
    query_count = length(queries)

    unless quiet do
      IO.puts("\n" <> String.duplicate("=", 60))
      IO.puts("#{label}: #{count} Concurrent Queries (#{query_count} variants)")
      IO.puts(String.duplicate("=", 60))
    end

    # Ensure inets is started for httpc
    :inets.start()

    start_time = System.monotonic_time(:millisecond)

    tasks =
      for idx <- 1..count do
        Task.async(fn ->
          query = Enum.at(queries, rem(idx - 1, query_count))
          query_start = System.monotonic_time(:millisecond)

          body = Jason.encode!(%{"query" => query})

          result =
            try do
              case :httpc.request(
                     :post,
                     {~c"#{@phoenix_url}", [], ~c"application/json", body},
                     [timeout: 120_000],
                     []
                   ) do
                {:ok, {{_, 200, _}, _, _response_body}} ->
                  :ok

                {:ok, {{_, status, _}, _, response_body}} ->
                  {:error, "HTTP #{status}: #{String.slice(to_string(response_body), 0, 100)}"}

                {:error, reason} ->
                  {:error, inspect(reason)}
              end
            rescue
              e -> {:error, Exception.message(e)}
            end

          query_end = System.monotonic_time(:millisecond)
          latency = query_end - query_start

          case result do
            :ok -> {:ok, latency}
            {:error, msg} -> {:error, msg, latency}
          end
        end)
      end

    results = Task.await_many(tasks, 300_000)
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
  defp format_throughput_growth(nil, nil), do: "n/a"
  defp format_throughput_growth(growth, pct) do
    sign = if growth < 0, do: "-", else: "+"
    "#{sign}#{round_num(abs(growth))} qps (#{sign}#{round_num(abs(pct))}%)"
  end

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

  defp print_three_way_comparison(http_metrics, adbc_metrics, phoenix_metrics) do
    IO.puts("""

    +----------------------+----------------+----------------+----------------+
    | Metric               | Cube HTTP      | ADBC Direct    | Phoenix/ADBC   |
    +----------------------+----------------+----------------+----------------+
    | Success Rate         | #{pad(http_metrics.success_rate, "%")} | #{pad(adbc_metrics.success_rate, "%")} | #{pad(phoenix_metrics.success_rate, "%")} |
    | Throughput (qps)     | #{pad(http_metrics.throughput, "")} | #{pad(adbc_metrics.throughput, "")} | #{pad(phoenix_metrics.throughput, "")} |
    | Avg Latency (ms)     | #{pad(http_metrics.avg_latency, "")} | #{pad(adbc_metrics.avg_latency, "")} | #{pad(phoenix_metrics.avg_latency, "")} |
    | P50 Latency (ms)     | #{pad(http_metrics.p50, "")} | #{pad(adbc_metrics.p50, "")} | #{pad(phoenix_metrics.p50, "")} |
    | P95 Latency (ms)     | #{pad(http_metrics.p95, "")} | #{pad(adbc_metrics.p95, "")} | #{pad(phoenix_metrics.p95, "")} |
    | P99 Latency (ms)     | #{pad(http_metrics.p99, "")} | #{pad(adbc_metrics.p99, "")} | #{pad(phoenix_metrics.p99, "")} |
    +----------------------+----------------+----------------+----------------+
    """)

    # Calculate speedups
    http_vs_adbc = if http_metrics.throughput > 0, do: adbc_metrics.throughput / http_metrics.throughput, else: 0
    http_vs_phoenix = if http_metrics.throughput > 0, do: phoenix_metrics.throughput / http_metrics.throughput, else: 0
    phoenix_vs_adbc = if phoenix_metrics.throughput > 0, do: adbc_metrics.throughput / phoenix_metrics.throughput, else: 0

    IO.puts("""
      ============================================================
      THROUGHPUT COMPARISON
      ============================================================
      ADBC Direct vs Cube HTTP:     #{round_num(http_vs_adbc)}x faster
      Phoenix/ADBC vs Cube HTTP:    #{round_num(http_vs_phoenix)}x faster
      ADBC Direct vs Phoenix/ADBC:  #{round_num(phoenix_vs_adbc)}x faster

      Phoenix adds HTTP overhead but retains most ADBC benefits:
      - Columnar JSON response format
      - Connection pooling via ADBC
      - Sub-second latency at scale
      ============================================================
    """)
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

    # Calculate and highlight ADBC throughput advantage
    throughput_speedup =
      if http_metrics.throughput > 0 do
        adbc_metrics.throughput / http_metrics.throughput
      else
        0
      end

    latency_speedup =
      if adbc_metrics.avg_latency > 0 do
        http_metrics.avg_latency / adbc_metrics.avg_latency
      else
        0
      end

    IO.puts("""
      ============================================================
      ADBC THROUGHPUT ADVANTAGE
      ============================================================
      Throughput Speedup:  #{round_num(throughput_speedup)}x faster queries per second
      Latency Reduction:   #{round_num(latency_speedup)}x lower response time

      KEY INSIGHT: ADBC delivers #{round_num(throughput_speedup)}x more queries
      per second than HTTP, enabling real-time analytics at scale.
      ============================================================
    """)
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
