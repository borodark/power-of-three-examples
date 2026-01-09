Running ExUnit with seed: 439350, max_cases: 176
Excluding tags: [:saturation, :cube, :broken_server, :saturation_1000]
Including tags: [:endurance, :live_cube]


============================================================
HTTP 100: 100 Concurrent Queries
============================================================

HTTP 100 Results:
  Total queries:     100
  Successes:         100
  Failures:          0
  Success rate:      100.0%

Latency (milliseconds) - Explorer Statistics:
  Average:           604.88ms
  Std Dev:           96.56ms
  Min:               508ms
  Max:               721ms
  P50 (median):      693ms
  P95:               719ms
  P99:               721ms

Performance:
  Total duration:    0.72s
  Throughput:        138.31 qps

.
============================================================
HTTP 1000: 1000 Concurrent Queries
============================================================

HTTP 1000 Results:
  Total queries:     1000
  Successes:         806
  Failures:          194
  Success rate:      80.6%

Latency (milliseconds) - Explorer Statistics:
  Average:           2663.55ms
  Std Dev:           1513.48ms
  Min:               318ms
  Max:               5229ms
  P50 (median):      2485ms
  P95:               5206ms
  P99:               5226ms

Performance:
  Total duration:    5.25s
  Throughput:        190.66 qps

  Sample errors:
    - Finch was unable to provide a connection within the timeout due to excess queuin
    - Finch was unable to provide a connection within the timeout due to excess queuin
    - Finch was unable to provide a connection within the timeout due to excess queuin
.
============================================================
HTTP: Pre-Aggregation vs No Pre-Aggregation (50 queries)
============================================================

+----------------------+----------------+----------------+
| Metric               | With Pre-Agg   | No Pre-Agg     |
+----------------------+----------------+----------------+
| Success Rate         |         100.0% |         100.0% |
| Throughput (qps)     |         158.73 |          20.64 |
| Avg Latency (ms)     |          302.2 |        2415.56 |
| P50 Latency (ms)     |            303 |           2415 |
| P95 Latency (ms)     |            311 |           2420 |
| P99 Latency (ms)     |            312 |           2421 |
+----------------------+----------------+----------------+

  Pre-Aggregation Speedup: 7.99x faster
.
======================================================================
HTTP Endurance: 800 Concurrent for 30 minutes
======================================================================
Started at: 2026-01-04 09:23:17.086316Z
[1 min elapsed, 28 min remaining] HTTP Endurance
├─ Requests: 9945 total (9895 ok, 50 failed)
├─ Success Rate: 99.5%
├─ Throughput: 165.75 qps
├─ Latency: avg=4618.38ms, p50=4762ms, p95=5046ms, p99=5255ms
└─ Std Dev: 695.95ms
======================================================================
FINAL REPORT: HTTP Endurance
======================================================================
Completed at: 2026-01-04 09:53:18.091517Z

Summary:
  Duration:          30 minutes
  Total Requests:    295130
  Successful:        292773
  Failed:            2357
  Success Rate:      99.2%
  Avg Throughput:    163.96 qps

Latency Statistics (Explorer):
  Average:           4920.85ms
  Std Deviation:     209.53ms
  Min:               4496ms
  Max:               5453ms
  P50 (median):      4895ms
  P95:               5243ms
  P99:               5314ms

  Sample Errors (last 5):
    - Finch was unable to provide a connection within the timeout due to exc
    - Finch was unable to provide a connection within the timeout due to exc
    - Finch was unable to provide a connection within the timeout due to exc
    - Finch was unable to provide a connection within the timeout due to exc
    - Finch was unable to provide a connection within the timeout due to exc

  Throughput Trend:
      1m: █████████████████ 165.75 qps (99.5%)
      2m: █████████████████ 165.42 qps (99.72%)
      3m: █████████████████ 165.56 qps (99.04%)
      4m: █████████████████ 165.31 qps (99.02%)
      5m: █████████████████ 165.01 qps (99.05%)
      6m: ████████████████ 164.52 qps (98.99%)
      7m: ████████████████ 164.56 qps (99.13%)
      8m: ████████████████ 164.42 qps (99.1%)
      9m: ████████████████ 164.31 qps (99.14%)
     10m: ████████████████ 164.21 qps (99.17%)
     11m: ████████████████ 164.42 qps (99.25%)
     12m: ████████████████ 164.62 qps (99.31%)
     13m: ████████████████ 164.51 qps (99.28%)
     14m: ████████████████ 164.46 qps (99.26%)
     15m: ████████████████ 164.67 qps (99.31%)
     16m: ████████████████ 164.32 qps (99.24%)
     17m: ████████████████ 164.26 qps (99.19%)
     18m: ████████████████ 164.2 qps (99.23%)
     19m: ████████████████ 164.01 qps (99.18%)
     20m: ████████████████ 163.93 qps (99.13%)
     21m: ████████████████ 163.83 qps (99.12%)
     22m: ████████████████ 163.69 qps (99.1%)
     23m: ████████████████ 163.67 qps (99.12%)
     24m: ████████████████ 163.63 qps (99.14%)
     25m: ████████████████ 163.77 qps (99.17%)
     26m: ████████████████ 163.71 qps (99.18%)
     27m: ████████████████ 163.84 qps (99.21%)
     28m: ████████████████ 163.88 qps (99.22%)
     29m: ████████████████ 163.91 qps (99.21%)
======================================================================
.
============================================================
ADBC 1000: 1000 Concurrent Queries (pool: 44)
============================================================

ADBC 1000 Results:
  Total queries:     1000
  Successes:         1000
  Failures:          0
  Success rate:      100.0%

Latency (milliseconds) - Explorer Statistics:
  Average:           10404.47ms
  Std Dev:           5649.32ms
  Min:               840ms
  Max:               19866ms
  P50 (median):      10366ms
  P95:               19086ms
  P99:               19724ms

Performance:
  Total duration:    19.89s
  Throughput:        50.28 qps

.
======================================================================
ADBC Quick Endurance: 100 Concurrent for 5 minutes
======================================================================
Started at: 2026-01-04 09:53:37.985512Z


[1 min elapsed, 3 min remaining] ADBC Quick Endurance
├─ Requests: 3033 total (3033 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 50.55 qps
├─ Latency: avg=1935.97ms, p50=1957ms, p95=2561ms, p99=2823ms
└─ Std Dev: 381.76ms
======================================================================
FINAL REPORT: ADBC Quick Endurance
======================================================================
Completed at: 2026-01-04 09:58:39.187399Z

Summary:
  Duration:          5 minutes
  Total Requests:    15092
  Successful:        15092
  Failed:            0
  Success Rate:      100.0%
  Avg Throughput:    50.31 qps

Latency Statistics (Explorer):
  Average:           1984.95ms
  Std Deviation:     618.74ms
  Min:               384ms
  Max:               4374ms
  P50 (median):      1929ms
  P95:               3121ms
  P99:               3524ms


  Throughput Trend:
      1m: █████ 50.55 qps (100.0%)
      2m: █████ 50.08 qps (100.0%)
      3m: █████ 49.79 qps (100.0%)
      4m: █████ 50.18 qps (100.0%)
======================================================================
.
======================================================================
ADBC Endurance: 800 Concurrent for 30 minutes
======================================================================
Started at: 2026-01-04 09:58:39.439088Z
[1 min elapsed, 28 min remaining] ADBC Endurance
├─ Requests: 2956 total (2956 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 49.26 qps
├─ Latency: avg=13967.38ms, p50=15634ms, p95=17125ms, p99=17502ms
└─ Std Dev: 4155.98ms
======================================================================
FINAL REPORT: ADBC Endurance
======================================================================
Completed at: 2026-01-04 10:28:40.692068Z

Summary:
  Duration:          30 minutes
  Total Requests:    92504
  Successful:        92504
  Failed:            0
  Success Rate:      100.0%
  Avg Throughput:    51.39 qps

Latency Statistics (Explorer):
  Average:           16054.67ms
  Std Deviation:     1598.25ms
  Min:               11750ms
  Max:               21190ms
  P50 (median):      16061ms
  P95:               18742ms
  P99:               19629ms


  Throughput Trend:
      1m: █████ 49.26 qps (100.0%)
      2m: █████ 49.63 qps (100.0%)
      3m: █████ 50.62 qps (100.0%)
      4m: █████ 50.81 qps (100.0%)
      5m: █████ 50.9 qps (100.0%)
      6m: █████ 51.02 qps (100.0%)
      7m: █████ 51.05 qps (100.0%)
      8m: █████ 51.13 qps (100.0%)
      9m: █████ 51.53 qps (100.0%)
     10m: █████ 52.38 qps (100.0%)
     11m: █████ 52.51 qps (100.0%)
     12m: █████ 52.42 qps (100.0%)
     13m: █████ 52.28 qps (100.0%)
     14m: █████ 52.17 qps (100.0%)
     15m: █████ 52.11 qps (100.0%)
     16m: █████ 52.04 qps (100.0%)
     17m: █████ 51.99 qps (100.0%)
     18m: █████ 51.91 qps (100.0%)
     19m: █████ 51.86 qps (100.0%)
     20m: █████ 51.82 qps (100.0%)
     21m: █████ 51.78 qps (100.0%)
     22m: █████ 51.74 qps (100.0%)
     23m: █████ 51.69 qps (100.0%)
     24m: █████ 51.69 qps (100.0%)
     25m: █████ 51.63 qps (100.0%)
     26m: █████ 51.59 qps (100.0%)
     27m: █████ 51.56 qps (100.0%)
     28m: █████ 51.52 qps (100.0%)
     29m: █████ 51.46 qps (100.0%)
======================================================================
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
  Average:           8915.35ms
  Std Dev:           1051.2ms
  Min:               5634ms
  Max:               10149ms
  P50 (median):      9228ms
  P95:               10023ms
  P99:               10109ms

Performance:
  Total duration:    10.15s
  Throughput:        9.85 qps

.
============================================================
ADBC: Pre-Aggregation vs No Pre-Aggregation (50 queries)
============================================================

+----------------------+----------------+----------------+
| Metric               | With Pre-Agg   | No Pre-Agg     |
+----------------------+----------------+----------------+
| Success Rate         |         100.0% |         100.0% |
| Throughput (qps)     |          49.75 |          18.75 |
| Avg Latency (ms)     |         838.16 |        2518.18 |
| P50 Latency (ms)     |            786 |           2482 |
| P95 Latency (ms)     |            990 |           2658 |
| P99 Latency (ms)     |           1003 |           2664 |
+----------------------+----------------+----------------+

  Pre-Aggregation Speedup: 3.0x faster
.
============================================================
COMPARISON: 100 Concurrent Queries (WITH Pre-Aggregation)
============================================================

+----------------------+----------------+----------------+
| Metric               | HTTP           | ADBC           |
+----------------------+----------------+----------------+
| Success Rate         |         100.0% |         100.0% |
| Throughput (qps)     |         106.16 |          40.36 |
| Avg Latency (ms)     |         628.56 |        1756.52 |
| P50 Latency (ms)     |            698 |           2172 |
| P95 Latency (ms)     |            903 |           2453 |
| P99 Latency (ms)     |            913 |           2475 |
+----------------------+----------------+----------------+

  Winner: HTTP
.
Finished in 3955.9 seconds (3955.9s async, 0.00s sync)
10 tests, 0 failures
