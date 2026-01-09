Running ExUnit with seed: 477335, max_cases: 176
Excluding tags: [:saturation, :cube, :broken_server, :saturation_1000]
Including tags: [:endurance, :live_cube]


============================================================
ADBC 100: 100 Concurrent Queries (512 variants, pool: 176)
============================================================

ADBC 100 Results:
  Total queries:     100
  Successes:         100
  Failures:          0
  Success rate:      100.0%

Latency (milliseconds) - Explorer Statistics:
  Average:           22195.12ms
  Std Dev:           16509.45ms
  Min:               2136ms
  Max:               52864ms
  P50 (median):      20223ms
  P95:               50534ms
  P99:               52416ms

Performance:
  Total duration:    52.93s
  Throughput:        1.89 qps

.
======================================================================
COMPARISON: 100 Concurrent × 512 Query Variations (mandata_captate)
10 years (2016-2025) × 6 granularities × 8 templates | LIMIT 1k-50k
======================================================================

+----------------------+----------------+----------------+----------------+
| Metric               | Cube HTTP      | ADBC Direct    | Phoenix/ADBC   |
+----------------------+----------------+----------------+----------------+
| Success Rate         |         100.0% |         100.0% |         100.0% |
| Throughput (qps)     |          14.87 |          46.49 |          19.42 |
| Avg Latency (ms)     |        3904.39 |          53.96 |        2200.69 |
| P50 Latency (ms)     |           4369 |             58 |           2293 |
| P95 Latency (ms)     |           5802 |             69 |           4882 |
| P99 Latency (ms)     |           6333 |             81 |           5111 |
+----------------------+----------------+----------------+----------------+

  ============================================================
  THROUGHPUT COMPARISON
  ============================================================
  ADBC Direct vs Cube HTTP:     3.13x faster
  Phoenix/ADBC vs Cube HTTP:    1.31x faster
  ADBC Direct vs Phoenix/ADBC:  2.39x faster

  Phoenix adds HTTP overhead but retains most ADBC benefits:
  - Columnar JSON response format
  - Connection pooling via ADBC
  - Sub-second latency at scale
  ============================================================

.
======================================================================
MANDATA CAPTATE: 100 Concurrent × 512 Query Variations (2016-2025)
======================================================================

============================================================
ADBC Mandata Variety: 100 Concurrent Queries (512 variants, pool: 176)
============================================================

ADBC Mandata Variety Results:
  Total queries:     100
  Successes:         100
  Failures:          0
  Success rate:      100.0%

Latency (milliseconds) - Explorer Statistics:
  Average:           49.45ms
  Std Dev:           12.27ms
  Min:               12ms
  Max:               81ms
  P50 (median):      52ms
  P95:               67ms
  P99:               70ms

Performance:
  Total duration:    2.37s
  Throughput:        42.28 qps

.Query variety: 512 mandata_captate combinations (2016-2025), LIMIT 1k-50k

======================================================================
Phoenix Endurance: 100 Concurrent for 15 minutes
======================================================================
Started at: 2026-01-07 23:28:10.949202Z
[1 min elapsed, 13 min remaining] Phoenix Endurance
├─ Requests: 2248 total (2248 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 37.47 qps
├─ Throughput Growth: n/a
├─ Latency: avg=2361.94ms, p50=1231ms, p95=7384ms, p99=15345ms
└─ Std Dev: 3083.89ms
======================================================================
FINAL REPORT: Phoenix Endurance
======================================================================
Completed at: 2026-01-07 23:43:11.958920Z

Summary:
  Duration:          15 minutes
  Total Requests:    43449
  Successful:        43449
  Failed:            0
  Success Rate:      100.0%

┌──────────────────────────────────────────────────────────────────┐
│  THROUGHPUT PERFORMANCE                                          │
├──────────────────────────────────────────────────────────────────┤
│  Avg Throughput:    48.28 qps                                    │
│  Throughput Growth: +10.98 qps (+29.3%)                          │
└──────────────────────────────────────────────────────────────────┘

Latency Statistics (Explorer):
  Average:           2042.68ms
  Std Deviation:     4915.47ms
  Min:               14ms
  Max:               38584ms
  P50 (median):      146ms
  P95:               13285ms
  P99:               23839ms


  Throughput Trend:
      1m: ████ 37.47 qps (100.0%)
      2m: ████ 44.41 qps (100.0%)
      3m: █████ 46.46 qps (100.0%)
      4m: █████ 47.3 qps (100.0%)
      5m: █████ 47.73 qps (100.0%)
      6m: █████ 48.05 qps (100.0%)
      7m: █████ 48.16 qps (100.0%)
      8m: █████ 47.66 qps (100.0%)
      9m: █████ 47.96 qps (100.0%)
     10m: █████ 48.3 qps (100.0%)
     11m: █████ 48.07 qps (100.0%)
     12m: █████ 48.05 qps (100.0%)
     13m: █████ 48.28 qps (100.0%)
     14m: █████ 48.44 qps (100.0%)
======================================================================

.Query variety: 512 mandata_captate combinations (2016-2025), LIMIT 1k-50k

======================================================================
ADBC Endurance: 100 Concurrent for 15 minutes
======================================================================
Started at: 2026-01-07 23:43:11.962124Z
[1 min elapsed, 13 min remaining] ADBC Endurance
├─ Requests: 14258 total (14258 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 237.63 qps
├─ Throughput Growth: n/a
├─ Latency: avg=319.64ms, p50=53ms, p95=1471ms, p99=1846ms
└─ Std Dev: 487.2ms
======================================================================
FINAL REPORT: ADBC Endurance
======================================================================
Completed at: 2026-01-07 23:58:12.967843Z

Summary:
  Duration:          15 minutes
  Total Requests:    261124
  Successful:        261124
  Failed:            0
  Success Rate:      100.0%

┌──────────────────────────────────────────────────────────────────┐
│  THROUGHPUT PERFORMANCE                                          │
├──────────────────────────────────────────────────────────────────┤
│  Avg Throughput:    290.14 qps                                   │
│  Throughput Growth: +52.47 qps (+22.08%)                         │
└──────────────────────────────────────────────────────────────────┘

Latency Statistics (Explorer):
  Average:           342.56ms
  Std Deviation:     510.98ms
  Min:               0ms
  Max:               2570ms
  P50 (median):      63ms
  P95:               1535ms
  P99:               1920ms


  Throughput Trend:
      1m: ████████████████████████ 237.63 qps (100.0%)
      2m: ███████████████████████████ 265.06 qps (100.0%)
      3m: ███████████████████████████ 273.43 qps (100.0%)
      4m: ████████████████████████████ 282.91 qps (100.0%)
      5m: █████████████████████████████ 289.29 qps (100.0%)
      6m: █████████████████████████████ 293.88 qps (100.0%)
      7m: █████████████████████████████ 293.88 qps (100.0%)
      8m: █████████████████████████████ 293.02 qps (100.0%)
      9m: █████████████████████████████ 292.24 qps (100.0%)
     10m: █████████████████████████████ 291.86 qps (100.0%)
     11m: █████████████████████████████ 291.48 qps (100.0%)
     12m: █████████████████████████████ 290.75 qps (100.0%)
     13m: █████████████████████████████ 290.3 qps (100.0%)
     14m: █████████████████████████████ 290.1 qps (100.0%)
======================================================================
.
======================================================================
ADBC MANDATA HIGH VOLUME: 1000 Concurrent Queries
======================================================================

============================================================
ADBC Mandata 1000: 1000 Concurrent Queries (512 variants, pool: 176)
============================================================

ADBC Mandata 1000 Results:
  Total queries:     1000
  Successes:         1000
  Failures:          0
  Success rate:      100.0%

Latency (milliseconds) - Explorer Statistics:
  Average:           268.44ms
  Std Dev:           121.96ms
  Min:               4ms
  Max:               463ms
  P50 (median):      254ms
  P95:               439ms
  P99:               445ms

Performance:
  Total duration:    27.57s
  Throughput:        36.27 qps

.
============================================================
ADBC: Pre-Aggregation vs No Pre-Aggregation (50 queries)
============================================================

+----------------------+----------------+----------------+
| Metric               | With Pre-Agg   | No Pre-Agg     |
+----------------------+----------------+----------------+
| Success Rate         |         100.0% |         100.0% |
| Throughput (qps)     |          31.73 |          39.31 |
| Avg Latency (ms)     |         1573.3 |         1269.4 |
| P50 Latency (ms)     |           1573 |           1269 |
| P95 Latency (ms)     |           1574 |           1270 |
| P99 Latency (ms)     |           1575 |           1272 |
+----------------------+----------------+----------------+

  Pre-Aggregation Speedup: 0.81x faster
.Query variety: 512 mandata_captate combinations (2016-2025), LIMIT 1k-50k

======================================================================
Phoenix Quick Endurance: 100 Concurrent for 5 minutes
======================================================================
Started at: 2026-01-07 23:58:43.398242Z

[1 min elapsed, 3 min remaining] Phoenix Quick Endurance
├─ Requests: 3153 total (3153 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 52.55 qps
├─ Throughput Growth: n/a
├─ Latency: avg=1665.61ms, p50=140ms, p95=10882ms, p99=21686ms
└─ Std Dev: 4119.25ms

======================================================================
FINAL REPORT: Phoenix Quick Endurance
======================================================================
Completed at: 2026-01-08 00:03:44.407578Z

Summary:
  Duration:          5 minutes
  Total Requests:    15051
  Successful:        15051
  Failed:            0
  Success Rate:      100.0%

┌──────────────────────────────────────────────────────────────────┐
│  THROUGHPUT PERFORMANCE                                          │
├──────────────────────────────────────────────────────────────────┤
│  Avg Throughput:    50.17 qps                                    │
│  Throughput Growth: -2.43 qps (-4.62%)                           │
└──────────────────────────────────────────────────────────────────┘

Latency Statistics (Explorer):
  Average:           2019.63ms
  Std Deviation:     4931.96ms
  Min:               21ms
  Max:               40025ms
  P50 (median):      144ms
  P95:               13185ms
  P99:               24023ms


  Throughput Trend:
      1m: █████ 52.55 qps (100.0%)
      2m: █████ 51.77 qps (100.0%)
      3m: █████ 50.59 qps (100.0%)
      4m: █████ 50.12 qps (100.0%)
======================================================================
.
============================================================
HTTP Variety 100: 100 Concurrent Queries (7 variants)
============================================================

HTTP Variety 100 Results:
  Total queries:     100
  Successes:         100
  Failures:          0
  Success rate:      100.0%

Latency (milliseconds) - Explorer Statistics:
  Average:           1264.77ms
  Std Dev:           529.7ms
  Min:               630ms
  Max:               2192ms
  P50 (median):      1110ms
  P95:               2191ms
  P99:               2192ms

Performance:
  Total duration:    2.2s
  Throughput:        45.52 qps

.
======================================================================
PHOENIX MANDATA: 100 Concurrent × 512 Query Variations (2016-2025)
======================================================================

============================================================
Phoenix Mandata Variety: 100 Concurrent Queries (512 variants)
============================================================

Phoenix Mandata Variety Results:
  Total queries:     100
  Successes:         100
  Failures:          0
  Success rate:      100.0%

Latency (milliseconds) - Explorer Statistics:
  Average:           3119.01ms
  Std Dev:           3509.11ms
  Min:               23ms
  Max:               9978ms
  P50 (median):      1169ms
  P95:               9486ms
  P99:               9697ms

Performance:
  Total duration:    9.98s
  Throughput:        10.02 qps

.Query variety: 512 mandata_captate combinations (2016-2025), LIMIT 1k-50k

======================================================================
ADBC Quick Endurance: 100 Concurrent for 5 minutes
======================================================================
Started at: 2026-01-08 00:03:56.589400Z
[1 min elapsed, 3 min remaining] ADBC Quick Endurance
├─ Requests: 17207 total (17207 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 286.77 qps
├─ Throughput Growth: n/a
├─ Latency: avg=308.81ms, p50=52ms, p95=1408ms, p99=1899ms
└─ Std Dev: 549.82ms
======================================================================
FINAL REPORT: ADBC Quick Endurance
======================================================================
Completed at: 2026-01-08 00:08:57.593864Z

Summary:
  Duration:          5 minutes
  Total Requests:    92824
  Successful:        92824
  Failed:            0
  Success Rate:      100.0%

┌──────────────────────────────────────────────────────────────────┐
│  THROUGHPUT PERFORMANCE                                          │
├──────────────────────────────────────────────────────────────────┤
│  Avg Throughput:    309.41 qps                                   │
│  Throughput Growth: +21.33 qps (+7.44%)                          │
└──────────────────────────────────────────────────────────────────┘

Latency Statistics (Explorer):
  Average:           315.33ms
  Std Deviation:     474.92ms
  Min:               0ms
  Max:               2931ms
  P50 (median):      55ms
  P95:               1420ms
  P99:               1804ms


  Throughput Trend:
      1m: █████████████████████████████ 286.77 qps (100.0%)
      2m: ██████████████████████████████ 299.41 qps (100.0%)
      3m: ██████████████████████████████ 303.93 qps (100.0%)
      4m: ███████████████████████████████ 308.11 qps (100.0%)
======================================================================
.
============================================================
ADBC 2_000: 2000 Concurrent Queries (512 variants, pool: 176)
============================================================

ADBC 2_000 Results:
  Total queries:     2000
  Successes:         2000
  Failures:          0
  Success rate:      100.0%

Latency (milliseconds) - Explorer Statistics:
  Average:           492.08ms
  Std Dev:           263.1ms
  Min:               14ms
  Max:               982ms
  P50 (median):      455ms
  P95:               926ms
  P99:               939ms

Performance:
  Total duration:    56.33s
  Throughput:        35.51 qps

.
======================================================================
MANDATA CAPTATE: Three-Way Comparison (100 Concurrent)
======================================================================

+----------------------+----------------+----------------+
| Metric               | ADBC Direct    | Phoenix/ADBC   |
+----------------------+----------------+----------------+
| Success Rate         |         100.0% |         100.0% |
| Throughput (qps)     |          44.35 |          19.35 |
| Avg Latency (ms)     |          44.48 |         1065.9 |
| P50 Latency (ms)     |             46 |            174 |
| P95 Latency (ms)     |             54 |           4659 |
| P99 Latency (ms)     |             58 |           4904 |
+----------------------+----------------+----------------+

Query variety: 512 combinations (75 date ranges × 6 granularities × 8 templates)
Date ranges: 2016-2025 (full years, halves, quarters, rolling periods)
Granularities: year, quarter, month, week, day, hour
LIMIT: varies 1,000 to 50,000 (50 different values)

.
============================================================
HTTP: Pre-Aggregation vs No Pre-Aggregation (50 queries)
============================================================

+----------------------+----------------+----------------+
| Metric               | With Pre-Agg   | No Pre-Agg     |
+----------------------+----------------+----------------+
| Success Rate         |         100.0% |         100.0% |
| Throughput (qps)     |          23.65 |          38.61 |
| Avg Latency (ms)     |        2092.14 |         1283.1 |
| P50 Latency (ms)     |           2101 |           1283 |
| P95 Latency (ms)     |           2111 |           1292 |
| P99 Latency (ms)     |           2113 |           1293 |
+----------------------+----------------+----------------+

  Pre-Aggregation Speedup: 0.61x faster
.Query variety: 512 mandata_captate combinations (2016-2025), LIMIT 1k-50k

======================================================================
HTTP Quick Endurance: 50 Concurrent for 5 minutes
======================================================================
Started at: 2026-01-08 00:10:04.766093Z
[1 min elapsed, 3 min remaining] HTTP Quick Endurance
├─ Requests: 1089 total (1089 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 18.15 qps
├─ Throughput Growth: n/a
├─ Latency: avg=2650.75ms, p50=2716ms, p95=5037ms, p99=6262ms
└─ Std Dev: 1817.15ms
======================================================================
FINAL REPORT: HTTP Quick Endurance
======================================================================
Completed at: 2026-01-08 00:15:05.770359Z

Summary:
  Duration:          5 minutes
  Total Requests:    6875
  Successful:        6875
  Failed:            0
  Success Rate:      100.0%

┌──────────────────────────────────────────────────────────────────┐
│  THROUGHPUT PERFORMANCE                                          │
├──────────────────────────────────────────────────────────────────┤
│  Avg Throughput:    22.92 qps                                    │
│  Throughput Growth: +4.27 qps (+23.53%)                          │
└──────────────────────────────────────────────────────────────────┘

Latency Statistics (Explorer):
  Average:           2169.61ms
  Std Deviation:     1280.33ms
  Min:               19ms
  Max:               27655ms
  P50 (median):      1959ms
  P95:               4391ms
  P99:               5539ms


  Throughput Trend:
      1m: ██ 18.15 qps (100.0%)
      2m: ██ 20.42 qps (100.0%)
      3m: ██ 21.83 qps (100.0%)
      4m: ██ 22.42 qps (100.0%)
======================================================================
.Query variety: 512 mandata_captate combinations (2016-2025), LIMIT 1k-50k

======================================================================
HTTP Endurance: 100 Concurrent for 15 minutes
======================================================================
Started at: 2026-01-08 00:15:05.774263Z
[1 min elapsed, 13 min remaining] HTTP Endurance
├─ Requests: 1406 total (1406 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 23.43 qps
├─ Throughput Growth: n/a
├─ Latency: avg=4050.88ms, p50=3960ms, p95=6157ms, p99=7409ms
└─ Std Dev: 1231.49ms
======================================================================
FINAL REPORT: HTTP Endurance
======================================================================
Completed at: 2026-01-08 00:30:06.778891Z

Summary:
  Duration:          15 minutes
  Total Requests:    22484
  Successful:        22484
  Failed:            0
  Success Rate:      100.0%

┌──────────────────────────────────────────────────────────────────┐
│  THROUGHPUT PERFORMANCE                                          │
├──────────────────────────────────────────────────────────────────┤
│  Avg Throughput:    24.98 qps                                    │
│  Throughput Growth: +1.4 qps (+5.98%)                            │
└──────────────────────────────────────────────────────────────────┘

Latency Statistics (Explorer):
  Average:           4003.55ms
  Std Deviation:     1181.89ms
  Min:               841ms
  Max:               9622ms
  P50 (median):      3858ms
  P95:               6225ms
  P99:               7431ms


  Throughput Trend:
      1m: ██ 23.43 qps (100.0%)
      2m: ██ 23.53 qps (100.0%)
      3m: ██ 23.43 qps (100.0%)
      4m: ██ 23.92 qps (100.0%)
      5m: ██ 24.45 qps (100.0%)
      6m: ██ 24.73 qps (100.0%)
      7m: ██ 24.79 qps (100.0%)
      8m: ██ 24.83 qps (100.0%)
      9m: ██ 24.79 qps (100.0%)
     10m: ██ 24.77 qps (100.0%)
     11m: ██ 24.66 qps (100.0%)
     12m: ██ 24.7 qps (100.0%)
     13m: ██ 24.87 qps (100.0%)
     14m: ██ 24.83 qps (100.0%)
======================================================================
.
============================================================
HTTP 100: 100 Concurrent Queries (512 variants)
============================================================

HTTP 100 Results:
  Total queries:     100
  Successes:         100
  Failures:          0
  Success rate:      100.0%

Latency (milliseconds) - Explorer Statistics:
  Average:           3698.45ms
  Std Dev:           1239.83ms
  Min:               1102ms
  Max:               6737ms
  P50 (median):      3710ms
  P95:               5905ms
  P99:               6011ms

Performance:
  Total duration:    6.74s
  Throughput:        14.83 qps

.
============================================================
Phoenix 100: 100 Concurrent Queries (512 variants)
============================================================

Phoenix 100 Results:
  Total queries:     100
  Successes:         100
  Failures:          0
  Success rate:      100.0%

Latency (milliseconds) - Explorer Statistics:
  Average:           5854.37ms
  Std Dev:           2694.66ms
  Min:               857ms
  Max:               10449ms
  P50 (median):      8059ms
  P95:               8895ms
  P99:               9642ms

Performance:
  Total duration:    10.45s
  Throughput:        9.57 qps

.
============================================================
ADBC Variety 100: 100 Concurrent Queries (7 variants, pool: 176)
============================================================

ADBC Variety 100 Results:
  Total queries:     100
  Successes:         100
  Failures:          0
  Success rate:      100.0%

Latency (milliseconds) - Explorer Statistics:
  Average:           1959.81ms
  Std Dev:           0.72ms
  Min:               1959ms
  Max:               1962ms
  P50 (median):      1960ms
  P95:               1961ms
  P99:               1961ms

Performance:
  Total duration:    2.02s
  Throughput:        49.63 qps

.
============================================================
Phoenix 1000: 1000 Concurrent Queries (512 variants)
============================================================

Phoenix 1000 Results:
  Total queries:     1000
  Successes:         1000
  Failures:          0
  Success rate:      100.0%

Latency (milliseconds) - Explorer Statistics:
  Average:           29081.19ms
  Std Dev:           14866.15ms
  Min:               28ms
  Max:               52122ms
  P50 (median):      37235ms
  P95:               47579ms
  P99:               50617ms

Performance:
  Total duration:    52.13s
  Throughput:        19.18 qps

.
Finished in 3858.6 seconds (3858.6s async, 0.00s sync)
20 tests, 0 failures
