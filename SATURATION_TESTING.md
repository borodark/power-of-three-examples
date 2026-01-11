# Cube ADBC Saturation Testing Guide

## Overview

Saturation tests verify cubesqld's ability to handle high concurrent query loads. These tests execute hundreds to thousands of concurrent queries to measure:

- **Throughput**: Queries per second (QPS)
- **Latency**: Response time distribution (avg, p50, p95, p99)
- **Reliability**: Success rate under load
- **Stability**: Sustained performance over time

## Test Scenarios

### 1. Fixed Concurrency Tests

**100 Concurrent Queries**
```bash
mix test test/cube_saturation_test.exs --include saturation_100
```

**1,000 Concurrent Queries**
```bash
mix test test/cube_saturation_test.exs --include saturation_1000
```

**10,000 Concurrent Queries**
```bash
mix test test/cube_saturation_test.exs --include saturation_10000
```

### 2. Progressive Load Test

Runs 100 → 1,000 → 10,000 queries in sequence:

```bash
mix test test/cube_saturation_test.exs --include progressive
```

### 3. Sustained Load Test

Maintains 100 QPS for 30 seconds:

```bash
mix test test/cube_saturation_test.exs --include sustained
```

### 4. Query Type Comparison

Compares performance across different query types:

```bash
mix test test/cube_saturation_test.exs --include query_comparison
```

### 5. Run All Saturation Tests

```bash
mix test test/cube_saturation_test.exs --include saturation
```

## Prerequisites

### 1. Start Cube Services

**Terminal 1: Cube.js API**
```bash
cd path/to/cube/examples/recipes/arrow-ipc
./start-cube-api.sh
```

**Terminal 2: cubesqld**
```bash
./start-cubesqld.sh
```

### 2. Verify Connection Pool

The saturation tests use `PowerOfThree.CubeConnectionPool` with default configuration:
- Pool size: `size` from config
- Host: localhost
- Port: 8120

### 3. Ensure System Resources

For 10,000 concurrent queries, ensure:
- **Memory**: At least 4GB available
- **File descriptors**: `ulimit -n` > 10,000
- **Elixir schedulers**: Default (CPU cores)

## Test Queries

Tests use realistic Cube queries from production scenarios:

1. **Simple dimension**: `SELECT orders.FUL FROM orders GROUP BY 1`
2. **Dimension + measure**: `SELECT orders.FUL, MEASURE(orders.count) ...`
3. **Multiple measures**: `SELECT orders.FUL, MEASURE(orders.count), MEASURE(orders.subtotal_amount) ...`
4. **Two dimensions**: `SELECT orders.FIN, orders.FUL, MEASURE(orders.count) ...`
5. **Simple SELECT**: `SELECT 1 as test`
6. **String query**: `SELECT 'hello' as greeting`

## Interpreting Results

### Sample Output

```
=== 1,000 Concurrent Queries ===
Results:
  Total queries:     1000
  Successes:         982
  Failures:          18
  Success rate:      98.20%

Latency (milliseconds):
  Average:           234.56ms
  Min:               45ms
  Max:               1250ms
  P50 (median):      198ms
  P95:               567ms
  P99:               892ms

Performance:
  Total duration:    5.67s
  Throughput:        176.37 qps
```

### Key Metrics

**Success Rate**
- **> 95%**: Excellent
- **90-95%**: Good
- **< 90%**: Issues, investigate errors

**P95 Latency**
- **< 500ms**: Excellent
- **500ms - 2s**: Acceptable
- **> 2s**: High latency, potential bottleneck

**Throughput**
- Measures concurrent query processing capacity
- Compare against expected production load

### Common Issues

**Low Success Rate (< 90%)**

Possible causes:
- Connection pool too small
- cubesqld connection limit reached
- Database timeout
- Memory exhaustion

**High Latency (P95 > 2s)**

Possible causes:
- Slow database queries
- Network latency
- cubesqld CPU saturation
- Cube.js API overload

**Decreasing Throughput**

Possible causes:
- Memory leak
- Connection leak
- Query queue buildup

## Optimizing Performance

### 1. Adjust Pool Size

```elixir
# config/config.exs
config :power_of_3, PowerOfThree.CubeConnectionPool,
  size: 20,  # Increase for higher concurrency
  host: "localhost",
  port: 8120,
  token: "test"
```

### 2. Monitor cubesqld

```bash
# Watch cubesqld logs
tail -f /path/to/cubesqld.log

# Monitor connections
lsof -i :8120 | wc -l
```

### 3. Database Optimization

- Add indexes for frequently queried dimensions
- Enable pre-aggregations in Cube.js
- Optimize Cube schema definitions

### 4. System Tuning

```bash
# Increase file descriptor limit
ulimit -n 65536

# Check Elixir scheduler count
elixir -e "IO.puts(System.schedulers_online())"
```

## Benchmarking Examples

### Baseline Performance Test

```bash
# Run 100 concurrent queries to establish baseline
mix test test/cube_saturation_test.exs --include saturation_100

# Note the throughput and P95 latency
# Example baseline: 150 qps, P95 250ms
```

### Stress Test

```bash
# Run progressive load to find breaking point
mix test test/cube_saturation_test.exs --include progressive

# Observe where success rate drops below 90%
```

### Sustained Load Test

```bash
# Verify system stability over time
mix test test/cube_saturation_test.exs --include sustained

# Check for degradation over 30 seconds
```

### Query Optimization Test

```bash
# Compare different query patterns
mix test test/cube_saturation_test.exs --include query_comparison

# Identify slow query types
# Optimize those queries in Cube schema
```

## Expected Performance

### Development Environment

**Hardware**: Multi-core CPU, localhost setup, Pool size: 10 connections

| Load | Success Rate | Throughput | P95 Latency | Avg Latency |
|------|--------------|------------|-------------|-------------|
| 100  | > 95% | 30-50 qps | 2-3s | 1-2s |
| 1,000 | > 90% | 10-30 qps | 30-60s | 20-40s |
| 10,000 | > 80% | 5-15 qps | 300-600s | 200-400s |

**Note**: Performance depends heavily on:
- Connection pool size (larger pool = higher concurrency)
- cubesqld configuration and hardware
- Query complexity (Cube queries are slower than simple SELECTs)
- Network latency (even localhost has some overhead)

### Production Environment

**Hardware**: 16-core CPU, 64GB RAM, network latency ~10ms

| Load | Success Rate | Throughput | P95 Latency |
|------|--------------|------------|-------------|
| 100  | > 99% | 300-400 qps | 150-250ms |
| 1,000 | > 98% | 250-350 qps | 300-500ms |
| 10,000 | > 95% | 200-300 qps | 500-1000ms |

## Continuous Testing

### CI/CD Integration

```bash
# Run quick saturation check (100 queries)
mix test test/cube_saturation_test.exs --include saturation_100

# Exit with failure if success rate < 95%
```

### Regular Benchmarking

```bash
# Weekly benchmark script
#!/bin/bash

echo "Weekly Cube Saturation Benchmark"
date

echo "=== 100 Concurrent Queries ==="
mix test test/cube_saturation_test.exs --include saturation_100

echo "=== 1,000 Concurrent Queries ==="
mix test test/cube_saturation_test.exs --include saturation_1000

echo "=== Progressive Load ==="
mix test test/cube_saturation_test.exs --include progressive

# Log results for trend analysis
```

## Troubleshooting

### Test Timeout

**Error**: `** (ExUnit.TimeoutError) test timed out after 300000ms`

**Solution**: Increase timeout in test file or reduce concurrency

### Connection Refused

**Error**: `{:error, :econnrefused}`

**Solution**: Ensure cubesqld is running on port 8120

### Out of Memory

**Error**: System becomes unresponsive

**Solution**:
- Reduce concurrent query count
- Increase system memory
- Check for memory leaks in cubesqld

### Too Many Open Files

**Error**: `{:error, :emfile}`

**Solution**:
```bash
ulimit -n 65536
```

## Advanced Usage

### Custom Query Sets

```elixir
# Create custom query list
@custom_queries [
  "SELECT ...",
  "SELECT ...",
]

# Run saturation with custom queries
run_saturation_test_with_queries(@custom_queries, 1000)
```

### Latency Distribution Analysis

```elixir
# Collect detailed latency data
latencies = run_detailed_saturation(1000)

# Plot histogram
:observer.start()  # View in observer
```

### Connection Pool Monitoring

```elixir
# Monitor pool during test
Task.async(fn ->
  for _ <- 1..30 do
    {_state, pool_size, _overflow, _busy, _waiting} =
      PowerOfThree.CubeConnectionPool.status()
    IO.puts("Pool size: #{pool_size}")
    Process.sleep(1000)
  end
end)
```

## Reporting

### Generate Performance Report

```bash
# Run all tests and save output
mix test test/cube_saturation_test.exs --include saturation > saturation_report.txt

# Extract metrics
grep "Success rate" saturation_report.txt
grep "Throughput" saturation_report.txt
```

### CSV Export (Future Enhancement)

```elixir
# Export metrics to CSV for analysis
defp export_to_csv(metrics, filename) do
  # Write metrics to CSV
end
```

## Related Documentation

- **Connection Pool Setup**: `CUBE_POOL_SETUP.md`
- **ADBC Testing**: `path/to/adbc/CUBE_TESTING_STATUS.md`
- **Architecture**: `path/to/adbc/ARCHITECTURE.md`

## Summary

Saturation tests provide critical insights into cubesqld's performance under load:

1. **Run regularly** to detect regressions
2. **Monitor metrics** for trends
3. **Optimize** based on results
4. **Document** baseline performance

Use these tests to ensure your Cube deployment can handle production traffic! 🚀
