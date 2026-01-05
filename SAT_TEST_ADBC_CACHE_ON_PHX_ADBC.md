Running ExUnit with seed: 977858, max_cases: 176
Excluding tags: [:saturation, :cube, :broken_server, :saturation_1000]
Including tags: [:endurance, :live_cube]


============================================================
ADBC: Pre-Aggregation vs No Pre-Aggregation (50 queries)
============================================================

+----------------------+----------------+----------------+
| Metric               | With Pre-Agg   | No Pre-Agg     |
+----------------------+----------------+----------------+
| Success Rate         |         100.0% |         100.0% |
| Throughput (qps)     |          17.37 |          25.04 |
| Avg Latency (ms)     |        2841.52 |        1992.86 |
| P50 Latency (ms)     |           2832 |           1993 |
| P95 Latency (ms)     |           2874 |           1993 |
| P99 Latency (ms)     |           2875 |           1995 |
+----------------------+----------------+----------------+

  Pre-Aggregation Speedup: 0.7x faster
.
======================================================================
ADBC Quick Endurance: 100 Concurrent for 5 minutes
======================================================================
Started at: 2026-01-04 23:04:17.674816Z


[1 min elapsed, 3 min remaining] ADBC Quick Endurance
├─ Requests: 232031 total (232031 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 3867.05 qps
├─ Latency: avg=0.38ms, p50=0ms, p95=1ms, p99=1ms
└─ Std Dev: 2.25ms


[2 min elapsed, 2 min remaining] ADBC Quick Endurance
├─ Requests: 466253 total (466253 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 3884.41 qps
├─ Latency: avg=0.45ms, p50=0ms, p95=1ms, p99=4ms
└─ Std Dev: 2.35ms


[3 min elapsed, 1 min remaining] ADBC Quick Endurance
├─ Requests: 705306 total (705306 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 3917.1 qps
├─ Latency: avg=0.73ms, p50=0ms, p95=1ms, p99=29ms
└─ Std Dev: 4.09ms


[4 min elapsed, 0 min remaining] ADBC Quick Endurance
├─ Requests: 948310 total (948310 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 3949.71 qps
├─ Latency: avg=0.34ms, p50=0ms, p95=1ms, p99=1ms
└─ Std Dev: 1.99ms


======================================================================
FINAL REPORT: ADBC Quick Endurance
======================================================================
Completed at: 2026-01-04 23:09:18.680219Z

Summary:
  Duration:          5 minutes
  Total Requests:    1185992
  Successful:        1185992
  Failed:            0
  Success Rate:      100.0%
  Avg Throughput:    3953.31 qps

Latency Statistics (Explorer):
  Average:           0.45ms
  Std Deviation:     2.77ms
  Min:               0ms
  Max:               42ms
  P50 (median):      0ms
  P95:               1ms
  P99:               3ms


  Throughput Trend:
      1m: ███████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████ 3867.05 qps (100.0%)
      2m: ████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████ 3884.41 qps (100.0%)
      3m: ████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████ 3917.1 qps (100.0%)
      4m: ███████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████ 3949.71 qps (100.0%)
======================================================================
.
============================================================
HTTP 1000: 1000 Concurrent Queries
============================================================

HTTP 1000 Results:
  Total queries:     1000
  Successes:         0
  Failures:          1000
  Success rate:      0.0%

Latency (milliseconds) - Explorer Statistics:
  Average:           0ms
  Std Dev:           0ms
  Min:               0ms
  Max:               0ms
  P50 (median):      0ms
  P95:               0ms
  P99:               0ms

Performance:
  Total duration:    1.01s
  Throughput:        989.12 qps

  Sample errors:
    - HTTP error 406
    - HTTP request failed
    - HTTP error 406
.
============================================================
ADBC 100: 100 Concurrent Queries (pool: 44)
============================================================

ADBC 100 Results:
  Total queries:     100
  Successes:         100
  Failures:          0
  Success rate:      100.0%

Latency (milliseconds) - Explorer Statistics:
  Average:           4.05ms
  Std Dev:           1.33ms
  Min:               1ms
  Max:               6ms
  P50 (median):      5ms
  P95:               6ms
  P99:               6ms

Performance:
  Total duration:    0.01s
  Throughput:        1.25e4 qps

.
======================================================================
HTTP Endurance: 800 Concurrent for 30 minutes
======================================================================
Started at: 2026-01-04 23:09:19.704400Z


[1 min elapsed, 28 min remaining] HTTP Endurance
├─ Requests: 69059 total (0 ok, 69059 failed)
├─ Success Rate: 0.0%
├─ Throughput: 1150.94 qps
├─ Latency: avg=0ms, p50=0ms, p95=0ms, p99=0ms
└─ Std Dev: 0ms


[2 min elapsed, 27 min remaining] HTTP Endurance
├─ Requests: 135178 total (0 ok, 135178 failed)
├─ Success Rate: 0.0%
├─ Throughput: 1126.46 qps
├─ Latency: avg=0ms, p50=0ms, p95=0ms, p99=0ms
└─ Std Dev: 0ms


[3 min elapsed, 26 min remaining] HTTP Endurance
├─ Requests: 201723 total (0 ok, 201723 failed)
├─ Success Rate: 0.0%
├─ Throughput: 1120.66 qps
├─ Latency: avg=0ms, p50=0ms, p95=0ms, p99=0ms
└─ Std Dev: 0ms


[4 min elapsed, 25 min remaining] HTTP Endurance
├─ Requests: 268128 total (0 ok, 268128 failed)
├─ Success Rate: 0.0%
├─ Throughput: 1117.18 qps
├─ Latency: avg=0ms, p50=0ms, p95=0ms, p99=0ms
└─ Std Dev: 0ms


[5 min elapsed, 24 min remaining] HTTP Endurance
├─ Requests: 335060 total (0 ok, 335060 failed)
├─ Success Rate: 0.0%
├─ Throughput: 1116.84 qps
├─ Latency: avg=0ms, p50=0ms, p95=0ms, p99=0ms
└─ Std Dev: 0ms


[6 min elapsed, 23 min remaining] HTTP Endurance
├─ Requests: 403129 total (0 ok, 403129 failed)
├─ Success Rate: 0.0%
├─ Throughput: 1119.78 qps
├─ Latency: avg=0ms, p50=0ms, p95=0ms, p99=0ms
└─ Std Dev: 0ms

