Running ExUnit with seed: 644351, max_cases: 176
Excluding tags: [:saturation, :cube, :broken_server, :saturation_1000]
Including tags: [:endurance, :live_cube]


======================================================================
ADBC Quick Endurance: 100 Concurrent for 5 minutes
======================================================================
Started at: 2026-01-04 20:43:37.400683Z


[1 min elapsed, 3 min remaining] ADBC Quick Endurance
├─ Requests: 221342 total (221342 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 3688.91 qps
├─ Latency: avg=0.43ms, p50=0ms, p95=1ms, p99=1ms
└─ Std Dev: 2.33ms


[2 min elapsed, 2 min remaining] ADBC Quick Endurance
├─ Requests: 449920 total (449920 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 3745.65 qps
├─ Latency: avg=0.35ms, p50=0ms, p95=1ms, p99=1ms
└─ Std Dev: 1.78ms


[3 min elapsed, 1 min remaining] ADBC Quick Endurance
├─ Requests: 694371 total (694371 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 3854.23 qps
├─ Latency: avg=0.37ms, p50=0ms, p95=1ms, p99=1ms
└─ Std Dev: 1.93ms


[4 min elapsed, 0 min remaining] ADBC Quick Endurance
├─ Requests: 929253 total (929253 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 3868.71 qps
├─ Latency: avg=0.37ms, p50=0ms, p95=1ms, p99=2ms
└─ Std Dev: 2.47ms


======================================================================
FINAL REPORT: ADBC Quick Endurance
======================================================================
Completed at: 2026-01-04 20:48:38.407029Z

Summary:
  Duration:          5 minutes
  Total Requests:    1179744
  Successful:        1179744
  Failed:            0
  Success Rate:      100.0%
  Avg Throughput:    3932.48 qps

Latency Statistics (Explorer):
  Average:           0.35ms
  Std Deviation:     1.97ms
  Min:               0ms
  Max:               42ms
  P50 (median):      0ms
  P95:               1ms
  P99:               1ms


  Throughput Trend:
      1m: █████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████ 3688.91 qps (100.0%)
      2m: ███████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████ 3745.65 qps (100.0%)
      3m: █████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████ 3854.23 qps (100.0%)
      4m: ███████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████ 3868.71 qps (100.0%)
======================================================================
.
============================================================
ADBC: Pre-Aggregation vs No Pre-Aggregation (50 queries)
============================================================

+----------------------+----------------+----------------+
| Metric               | With Pre-Agg   | No Pre-Agg     |
+----------------------+----------------+----------------+
| Success Rate         |         100.0% |         100.0% |
| Throughput (qps)     |          1.0e4 |          1.0e4 |
| Avg Latency (ms)     |           3.02 |            3.0 |
| P50 Latency (ms)     |              3 |              3 |
| P95 Latency (ms)     |              4 |              4 |
| P99 Latency (ms)     |              4 |              4 |
+----------------------+----------------+----------------+

  Pre-Aggregation Speedup: 0.99x faster
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
  Average:           28.26ms
  Std Dev:           16.58ms
  Min:               2ms
  Max:               102ms
  P50 (median):      28ms
  P95:               51ms
  P99:               101ms

Performance:
  Total duration:    0.11s
  Throughput:        8849.56 qps

.
============================================================
HTTP: Pre-Aggregation vs No Pre-Aggregation (50 queries)
============================================================

+----------------------+----------------+----------------+
| Metric               | With Pre-Agg   | No Pre-Agg     |
+----------------------+----------------+----------------+
| Success Rate         |         100.0% |         100.0% |
| Throughput (qps)     |          68.49 |          18.62 |
| Avg Latency (ms)     |          639.1 |         2677.5 |
| P50 Latency (ms)     |            628 |           2677 |
| P95 Latency (ms)     |            724 |           2683 |
| P99 Latency (ms)     |            728 |           2684 |
+----------------------+----------------+----------------+

  Pre-Aggregation Speedup: 4.19x faster
.
============================================================
HTTP 100: 100 Concurrent Queries
============================================================

HTTP 100 Results:
  Total queries:     100
  Successes:         100
  Failures:          0
  Success rate:      100.0%

Latency (milliseconds) - Explorer Statistics:
  Average:           402.25ms
  Std Dev:           138.64ms
  Min:               221ms
  Max:               556ms
  P50 (median):      515ms
  P95:               555ms
  P99:               556ms

Performance:
  Total duration:    0.56s
  Throughput:        178.89 qps

.
======================================================================
HTTP Endurance: 800 Concurrent for 30 minutes
======================================================================
Started at: 2026-01-04 20:48:42.512907Z


[1 min elapsed, 28 min remaining] HTTP Endurance
├─ Requests: 9428 total (9117 ok, 311 failed)
├─ Success Rate: 96.7%
├─ Throughput: 157.13 qps
├─ Latency: avg=4863.7ms, p50=5065ms, p95=5327ms, p99=5376ms
└─ Std Dev: 834.53ms


[2 min elapsed, 27 min remaining] HTTP Endurance
├─ Requests: 18788 total (18238 ok, 550 failed)
├─ Success Rate: 97.07%
├─ Throughput: 156.56 qps
├─ Latency: avg=5091.82ms, p50=5106ms, p95=5304ms, p99=5348ms
└─ Std Dev: 147.89ms


[3 min elapsed, 26 min remaining] HTTP Endurance
├─ Requests: 27932 total (26569 ok, 1363 failed)
├─ Success Rate: 95.12%
├─ Throughput: 155.17 qps
├─ Latency: avg=5218.57ms, p50=5239ms, p95=5368ms, p99=5405ms
└─ Std Dev: 128.29ms


[4 min elapsed, 25 min remaining] HTTP Endurance
├─ Requests: 37372 total (35756 ok, 1616 failed)
├─ Success Rate: 95.68%
├─ Throughput: 155.71 qps
├─ Latency: avg=5121.61ms, p50=5129ms, p95=5332ms, p99=5375ms
└─ Std Dev: 139.05ms


[5 min elapsed, 24 min remaining] HTTP Endurance
├─ Requests: 46721 total (44807 ok, 1914 failed)
├─ Success Rate: 95.9%
├─ Throughput: 155.73 qps
├─ Latency: avg=5088.15ms, p50=5102ms, p95=5308ms, p99=5417ms
└─ Std Dev: 155.42ms


[6 min elapsed, 23 min remaining] HTTP Endurance
├─ Requests: 56111 total (54075 ok, 2036 failed)
├─ Success Rate: 96.37%
├─ Throughput: 155.85 qps
├─ Latency: avg=5107.45ms, p50=5122ms, p95=5288ms, p99=5337ms
└─ Std Dev: 123.47ms


[7 min elapsed, 22 min remaining] HTTP Endurance
├─ Requests: 65348 total (62825 ok, 2523 failed)
├─ Success Rate: 96.14%
├─ Throughput: 155.58 qps
├─ Latency: avg=5161.76ms, p50=5172ms, p95=5333ms, p99=5395ms
└─ Std Dev: 116.75ms


[8 min elapsed, 21 min remaining] HTTP Endurance
├─ Requests: 74592 total (71398 ok, 3194 failed)
├─ Success Rate: 95.72%
├─ Throughput: 155.39 qps
├─ Latency: avg=5191.44ms, p50=5191ms, p95=5361ms, p99=5400ms
└─ Std Dev: 106.2ms


[9 min elapsed, 20 min remaining] HTTP Endurance
├─ Requests: 84036 total (80690 ok, 3346 failed)
├─ Success Rate: 96.02%
├─ Throughput: 155.61 qps
├─ Latency: avg=5099.3ms, p50=5107ms, p95=5326ms, p99=5382ms
└─ Std Dev: 143.9ms


[10 min elapsed, 19 min remaining] HTTP Endurance
├─ Requests: 93314 total (89166 ok, 4148 failed)
├─ Success Rate: 95.55%
├─ Throughput: 155.51 qps
├─ Latency: avg=5148.28ms, p50=5192ms, p95=5381ms, p99=5455ms
└─ Std Dev: 168.45ms


[11 min elapsed, 18 min remaining] HTTP Endurance
├─ Requests: 102545 total (97769 ok, 4776 failed)
├─ Success Rate: 95.34%
├─ Throughput: 155.36 qps
├─ Latency: avg=5191.05ms, p50=5204ms, p95=5361ms, p99=5413ms
└─ Std Dev: 131.22ms


[12 min elapsed, 17 min remaining] HTTP Endurance
├─ Requests: 111808 total (106615 ok, 5193 failed)
├─ Success Rate: 95.36%
├─ Throughput: 155.28 qps
├─ Latency: avg=5175.75ms, p50=5191ms, p95=5342ms, p99=5378ms
└─ Std Dev: 121.94ms


[13 min elapsed, 16 min remaining] HTTP Endurance
├─ Requests: 121224 total (115590 ok, 5634 failed)
├─ Success Rate: 95.35%
├─ Throughput: 155.41 qps
├─ Latency: avg=5102.93ms, p50=5165ms, p95=5347ms, p99=5396ms
└─ Std Dev: 212.08ms


[14 min elapsed, 15 min remaining] HTTP Endurance
├─ Requests: 130538 total (124489 ok, 6049 failed)
├─ Success Rate: 95.37%
├─ Throughput: 155.39 qps
├─ Latency: avg=5152.09ms, p50=5160ms, p95=5348ms, p99=5383ms
└─ Std Dev: 138.81ms


[15 min elapsed, 14 min remaining] HTTP Endurance
├─ Requests: 139795 total (132976 ok, 6819 failed)
├─ Success Rate: 95.12%
├─ Throughput: 155.32 qps
├─ Latency: avg=5176.99ms, p50=5212ms, p95=5362ms, p99=5397ms
└─ Std Dev: 154.5ms


[16 min elapsed, 13 min remaining] HTTP Endurance
├─ Requests: 149014 total (141600 ok, 7414 failed)
├─ Success Rate: 95.02%
├─ Throughput: 155.21 qps
├─ Latency: avg=5205.78ms, p50=5231ms, p95=5362ms, p99=5472ms
└─ Std Dev: 138.71ms


[17 min elapsed, 12 min remaining] HTTP Endurance
├─ Requests: 158398 total (150486 ok, 7912 failed)
├─ Success Rate: 95.0%
├─ Throughput: 155.28 qps
├─ Latency: avg=5141.76ms, p50=5163ms, p95=5363ms, p99=5464ms
└─ Std Dev: 159.1ms


[18 min elapsed, 11 min remaining] HTTP Endurance
├─ Requests: 167765 total (159369 ok, 8396 failed)
├─ Success Rate: 95.0%
├─ Throughput: 155.33 qps
├─ Latency: avg=5118.74ms, p50=5154ms, p95=5347ms, p99=5401ms
└─ Std Dev: 169.14ms


[19 min elapsed, 10 min remaining] HTTP Endurance
├─ Requests: 177108 total (168370 ok, 8738 failed)
├─ Success Rate: 95.07%
├─ Throughput: 155.35 qps
├─ Latency: avg=5118.11ms, p50=5123ms, p95=5320ms, p99=5388ms
└─ Std Dev: 137.47ms


[20 min elapsed, 9 min remaining] HTTP Endurance
├─ Requests: 186328 total (176996 ok, 9332 failed)
├─ Success Rate: 94.99%
├─ Throughput: 155.26 qps
├─ Latency: avg=5183.55ms, p50=5193ms, p95=5353ms, p99=5392ms
└─ Std Dev: 120.8ms


[21 min elapsed, 8 min remaining] HTTP Endurance
├─ Requests: 195633 total (185719 ok, 9914 failed)
├─ Success Rate: 94.93%
├─ Throughput: 155.25 qps
├─ Latency: avg=5165.41ms, p50=5183ms, p95=5363ms, p99=5410ms
└─ Std Dev: 140.96ms


[22 min elapsed, 7 min remaining] HTTP Endurance
├─ Requests: 205076 total (195031 ok, 10045 failed)
├─ Success Rate: 95.1%
├─ Throughput: 155.35 qps
├─ Latency: avg=5072.52ms, p50=5077ms, p95=5260ms, p99=5335ms
└─ Std Dev: 116.19ms


[23 min elapsed, 6 min remaining] HTTP Endurance
├─ Requests: 214545 total (204421 ok, 10124 failed)
├─ Success Rate: 95.28%
├─ Throughput: 155.46 qps
├─ Latency: avg=5071.38ms, p50=5079ms, p95=5281ms, p99=5336ms
└─ Std Dev: 138.83ms


[24 min elapsed, 5 min remaining] HTTP Endurance
├─ Requests: 223794 total (212942 ok, 10852 failed)
├─ Success Rate: 95.15%
├─ Throughput: 155.4 qps
├─ Latency: avg=5172.69ms, p50=5198ms, p95=5367ms, p99=5422ms
└─ Std Dev: 149.25ms


[25 min elapsed, 4 min remaining] HTTP Endurance
├─ Requests: 233041 total (221479 ok, 11562 failed)
├─ Success Rate: 95.04%
├─ Throughput: 155.35 qps
├─ Latency: avg=5196.75ms, p50=5202ms, p95=5362ms, p99=5414ms
└─ Std Dev: 116.4ms


[26 min elapsed, 3 min remaining] HTTP Endurance
├─ Requests: 242323 total (230237 ok, 12086 failed)
├─ Success Rate: 95.01%
├─ Throughput: 155.32 qps
├─ Latency: avg=5173.58ms, p50=5182ms, p95=5358ms, p99=5399ms
└─ Std Dev: 123.23ms


[27 min elapsed, 2 min remaining] HTTP Endurance
├─ Requests: 251540 total (238845 ok, 12695 failed)
├─ Success Rate: 94.95%
├─ Throughput: 155.26 qps
├─ Latency: avg=5198.54ms, p50=5202ms, p95=5347ms, p99=5403ms
└─ Std Dev: 107.45ms


[28 min elapsed, 1 min remaining] HTTP Endurance
├─ Requests: 260804 total (247656 ok, 13148 failed)
├─ Success Rate: 94.96%
├─ Throughput: 155.23 qps
├─ Latency: avg=5179.74ms, p50=5207ms, p95=5342ms, p99=5389ms
└─ Std Dev: 126.78ms


[29 min elapsed, 0 min remaining] HTTP Endurance
├─ Requests: 270189 total (256701 ok, 13488 failed)
├─ Success Rate: 95.01%
├─ Throughput: 155.27 qps
├─ Latency: avg=5111.96ms, p50=5122ms, p95=5333ms, p99=5375ms
└─ Std Dev: 152.51ms


======================================================================
FINAL REPORT: HTTP Endurance
======================================================================
Completed at: 2026-01-04 21:18:43.517450Z

Summary:
  Duration:          30 minutes
  Total Requests:    279581
  Successful:        265394
  Failed:            14187
  Success Rate:      94.93%
  Avg Throughput:    155.32 qps

Latency Statistics (Explorer):
  Average:           5212.4ms
  Std Deviation:     108.79ms
  Min:               4907ms
  Max:               5637ms
  P50 (median):      5224ms
  P95:               5373ms
  P99:               5412ms

  Sample Errors (last 5):
    - Finch was unable to provide a connection within the timeout due to exc
    - Finch was unable to provide a connection within the timeout due to exc
    - Finch was unable to provide a connection within the timeout due to exc
    - Finch was unable to provide a connection within the timeout due to exc
    - Finch was unable to provide a connection within the timeout due to exc

  Throughput Trend:
      1m: ████████████████ 157.13 qps (96.7%)
      2m: ████████████████ 156.56 qps (97.07%)
      3m: ████████████████ 155.17 qps (95.12%)
      4m: ████████████████ 155.71 qps (95.68%)
      5m: ████████████████ 155.73 qps (95.9%)
      6m: ████████████████ 155.85 qps (96.37%)
      7m: ████████████████ 155.58 qps (96.14%)
      8m: ████████████████ 155.39 qps (95.72%)
      9m: ████████████████ 155.61 qps (96.02%)
     10m: ████████████████ 155.51 qps (95.55%)
     11m: ████████████████ 155.36 qps (95.34%)
     12m: ████████████████ 155.28 qps (95.36%)
     13m: ████████████████ 155.41 qps (95.35%)
     14m: ████████████████ 155.39 qps (95.37%)
     15m: ████████████████ 155.32 qps (95.12%)
     16m: ████████████████ 155.21 qps (95.02%)
     17m: ████████████████ 155.28 qps (95.0%)
     18m: ████████████████ 155.33 qps (95.0%)
     19m: ████████████████ 155.35 qps (95.07%)
     20m: ████████████████ 155.26 qps (94.99%)
     21m: ████████████████ 155.25 qps (94.93%)
     22m: ████████████████ 155.35 qps (95.1%)
     23m: ████████████████ 155.46 qps (95.28%)
     24m: ████████████████ 155.4 qps (95.15%)
     25m: ████████████████ 155.35 qps (95.04%)
     26m: ████████████████ 155.32 qps (95.01%)
     27m: ████████████████ 155.26 qps (94.95%)
     28m: ████████████████ 155.23 qps (94.96%)
     29m: ████████████████ 155.27 qps (95.01%)
======================================================================
.
============================================================
COMPARISON: 100 Concurrent Queries (WITH Pre-Aggregation)
============================================================

+----------------------+----------------+----------------+
| Metric               | HTTP           | ADBC           |
+----------------------+----------------+----------------+
| Success Rate         |         100.0% |         100.0% |
| Throughput (qps)     |           93.9 |        8333.33 |
| Avg Latency (ms)     |         725.69 |           7.49 |
| P50 Latency (ms)     |            792 |              8 |
| P95 Latency (ms)     |           1040 |             10 |
| P99 Latency (ms)     |           1062 |             10 |
+----------------------+----------------+----------------+

  Winner: ADBC
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
  Average:           5.63ms
  Std Dev:           1.68ms
  Min:               3ms
  Max:               8ms
  P50 (median):      6ms
  P95:               8ms
  P99:               8ms

Performance:
  Total duration:    0.01s
  Throughput:        1.0e4 qps

.
======================================================================
ADBC Endurance: 800 Concurrent for 30 minutes
======================================================================
Started at: 2026-01-04 21:18:44.611887Z


[1 min elapsed, 28 min remaining] ADBC Endurance
├─ Requests: 220686 total (220686 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 3677.98 qps
├─ Latency: avg=0.3ms, p50=0ms, p95=1ms, p99=1ms
└─ Std Dev: 2.27ms


[2 min elapsed, 27 min remaining] ADBC Endurance
├─ Requests: 451290 total (451290 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 3749.56 qps
├─ Latency: avg=0.46ms, p50=0ms, p95=1ms, p99=1ms
└─ Std Dev: 2.2ms


[3 min elapsed, 26 min remaining] ADBC Endurance
├─ Requests: 663954 total (663954 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 3673.82 qps
├─ Latency: avg=0.38ms, p50=0ms, p95=1ms, p99=1ms
└─ Std Dev: 2.13ms


[4 min elapsed, 25 min remaining] ADBC Endurance
├─ Requests: 893704 total (893704 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 3707.61 qps
├─ Latency: avg=0.39ms, p50=0ms, p95=1ms, p99=1ms
└─ Std Dev: 2.34ms


[5 min elapsed, 24 min remaining] ADBC Endurance
├─ Requests: 1112034 total (1112034 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 3689.79 qps
├─ Latency: avg=0.37ms, p50=0ms, p95=1ms, p99=1ms
└─ Std Dev: 2.27ms


[6 min elapsed, 23 min remaining] ADBC Endurance
├─ Requests: 1338087 total (1338087 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 3699.45 qps
├─ Latency: avg=0.42ms, p50=0ms, p95=1ms, p99=1ms
└─ Std Dev: 2.44ms


[7 min elapsed, 22 min remaining] ADBC Endurance
├─ Requests: 1533280 total (1533280 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 3632.46 qps
├─ Latency: avg=0.48ms, p50=0ms, p95=1ms, p99=2ms
└─ Std Dev: 2.37ms


[8 min elapsed, 21 min remaining] ADBC Endurance
├─ Requests: 1713532 total (1713532 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 3551.24 qps
├─ Latency: avg=0.51ms, p50=0ms, p95=1ms, p99=1ms
└─ Std Dev: 2.09ms


[9 min elapsed, 20 min remaining] ADBC Endurance
├─ Requests: 1920100 total (1920100 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 3535.54 qps
├─ Latency: avg=0.33ms, p50=0ms, p95=1ms, p99=1ms
└─ Std Dev: 2.0ms


[10 min elapsed, 19 min remaining] ADBC Endurance
├─ Requests: 2119728 total (2119728 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 3511.94 qps
├─ Latency: avg=0.53ms, p50=0ms, p95=1ms, p99=1ms
└─ Std Dev: 2.38ms


[11 min elapsed, 18 min remaining] ADBC Endurance
├─ Requests: 2334351 total (2334351 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 3515.47 qps
├─ Latency: avg=0.41ms, p50=0ms, p95=1ms, p99=1ms
└─ Std Dev: 1.94ms


[12 min elapsed, 17 min remaining] ADBC Endurance
├─ Requests: 2537460 total (2537460 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 3502.1 qps
├─ Latency: avg=0.51ms, p50=0ms, p95=1ms, p99=1ms
└─ Std Dev: 2.47ms


[13 min elapsed, 16 min remaining] ADBC Endurance
├─ Requests: 2738751 total (2738751 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 3489.12 qps
├─ Latency: avg=0.58ms, p50=0ms, p95=1ms, p99=11ms
└─ Std Dev: 2.6ms


[14 min elapsed, 15 min remaining] ADBC Endurance
├─ Requests: 2946810 total (2946810 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 3475.19 qps
├─ Latency: avg=0.49ms, p50=0ms, p95=1ms, p99=1ms
└─ Std Dev: 2.48ms


[15 min elapsed, 14 min remaining] ADBC Endurance
├─ Requests: 3161432 total (3161432 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 3480.49 qps
├─ Latency: avg=0.47ms, p50=0ms, p95=1ms, p99=1ms
└─ Std Dev: 1.98ms


[16 min elapsed, 13 min remaining] ADBC Endurance
├─ Requests: 3371502 total (3371502 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 3479.93 qps
├─ Latency: avg=0.4ms, p50=0ms, p95=1ms, p99=1ms
└─ Std Dev: 1.96ms


[17 min elapsed, 12 min remaining] ADBC Endurance
├─ Requests: 3558266 total (3558266 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 3457.1 qps
├─ Latency: avg=0.35ms, p50=0ms, p95=1ms, p99=1ms
└─ Std Dev: 1.24ms


[18 min elapsed, 11 min remaining] ADBC Endurance
├─ Requests: 3784495 total (3784495 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 3472.91 qps
├─ Latency: avg=0.5ms, p50=0ms, p95=1ms, p99=1ms
└─ Std Dev: 2.53ms


[19 min elapsed, 10 min remaining] ADBC Endurance
├─ Requests: 3978162 total (3978162 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 3457.99 qps
├─ Latency: avg=0.49ms, p50=0ms, p95=1ms, p99=1ms
└─ Std Dev: 2.43ms


[20 min elapsed, 9 min remaining] ADBC Endurance
├─ Requests: 4189957 total (4189957 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 3460.09 qps
├─ Latency: avg=0.5ms, p50=0ms, p95=1ms, p99=1ms
└─ Std Dev: 2.13ms


[21 min elapsed, 8 min remaining] ADBC Endurance
├─ Requests: 4394022 total (4394022 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 3456.01 qps
├─ Latency: avg=0.48ms, p50=0ms, p95=1ms, p99=1ms
└─ Std Dev: 2.3ms


[22 min elapsed, 7 min remaining] ADBC Endurance
├─ Requests: 4569983 total (4569983 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 3431.15 qps
├─ Latency: avg=0.44ms, p50=0ms, p95=1ms, p99=1ms
└─ Std Dev: 1.93ms


[23 min elapsed, 6 min remaining] ADBC Endurance
├─ Requests: 4757008 total (4757008 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 3416.47 qps
├─ Latency: avg=0.55ms, p50=0ms, p95=1ms, p99=2ms
└─ Std Dev: 2.7ms


[24 min elapsed, 5 min remaining] ADBC Endurance
├─ Requests: 4960609 total (4960609 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 3414.45 qps
├─ Latency: avg=0.38ms, p50=0ms, p95=1ms, p99=1ms
└─ Std Dev: 1.71ms


[25 min elapsed, 4 min remaining] ADBC Endurance
├─ Requests: 5151784 total (5151784 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 3404.51 qps
├─ Latency: avg=0.53ms, p50=0ms, p95=1ms, p99=2ms
└─ Std Dev: 2.55ms


[26 min elapsed, 3 min remaining] ADBC Endurance
├─ Requests: 5354637 total (5354637 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 3402.44 qps
├─ Latency: avg=0.6ms, p50=0ms, p95=1ms, p99=4ms
└─ Std Dev: 2.89ms


[27 min elapsed, 2 min remaining] ADBC Endurance
├─ Requests: 5534474 total (5534474 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 3386.6 qps
├─ Latency: avg=0.36ms, p50=0ms, p95=1ms, p99=1ms
└─ Std Dev: 1.84ms


[28 min elapsed, 1 min remaining] ADBC Endurance
├─ Requests: 5727034 total (5727034 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 3379.41 qps
├─ Latency: avg=0.48ms, p50=0ms, p95=1ms, p99=1ms
└─ Std Dev: 2.0ms


[29 min elapsed, 0 min remaining] ADBC Endurance
├─ Requests: 5907456 total (5907456 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 3365.56 qps
├─ Latency: avg=0.45ms, p50=0ms, p95=1ms, p99=1ms
└─ Std Dev: 1.77ms


======================================================================
FINAL REPORT: ADBC Endurance
======================================================================
Completed at: 2026-01-04 21:48:45.617934Z

Summary:
  Duration:          30 minutes
  Total Requests:    6036439
  Successful:        6036439
  Failed:            0
  Success Rate:      100.0%
  Avg Throughput:    3353.58 qps

Latency Statistics (Explorer):
  Average:           0.49ms
  Std Deviation:     2.27ms
  Min:               0ms
  Max:               43ms
  P50 (median):      0ms
  P95:               1ms
  P99:               1ms


  Throughput Trend:
      1m: ████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████ 3677.98 qps (100.0%)
      2m: ███████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████ 3749.56 qps (100.0%)
      3m: ███████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████ 3673.82 qps (100.0%)
      4m: ███████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████ 3707.61 qps (100.0%)
      5m: █████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████ 3689.79 qps (100.0%)
      6m: ██████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████ 3699.45 qps (100.0%)
      7m: ███████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████ 3632.46 qps (100.0%)
      8m: ███████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████ 3551.24 qps (100.0%)
      9m: ██████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████ 3535.54 qps (100.0%)
     10m: ███████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████ 3511.94 qps (100.0%)
     11m: ████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████ 3515.47 qps (100.0%)
     12m: ██████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████ 3502.1 qps (100.0%)
     13m: █████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████ 3489.12 qps (100.0%)
     14m: ████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████ 3475.19 qps (100.0%)
     15m: ████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████ 3480.49 qps (100.0%)
     16m: ████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████ 3479.93 qps (100.0%)
     17m: ██████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████ 3457.1 qps (100.0%)
     18m: ███████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████ 3472.91 qps (100.0%)
     19m: ██████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████ 3457.99 qps (100.0%)
     20m: ██████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████ 3460.09 qps (100.0%)
     21m: ██████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████ 3456.01 qps (100.0%)
     22m: ███████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████ 3431.15 qps (100.0%)
     23m: ██████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████ 3416.47 qps (100.0%)
     24m: █████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████ 3414.45 qps (100.0%)
     25m: ████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████ 3404.51 qps (100.0%)
     26m: ████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████ 3402.44 qps (100.0%)
     27m: ███████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████ 3386.6 qps (100.0%)
     28m: ██████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████ 3379.41 qps (100.0%)
     29m: █████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████ 3365.56 qps (100.0%)
======================================================================
.
============================================================
HTTP 1000: 1000 Concurrent Queries
============================================================

HTTP 1000 Results:
  Total queries:     1000
  Successes:         562
  Failures:          438
  Success rate:      56.2%

Latency (milliseconds) - Explorer Statistics:
  Average:           2996.69ms
  Std Dev:           1519.24ms
  Min:               291ms
  Max:               5244ms
  P50 (median):      3033ms
  P95:               5146ms
  P99:               5234ms

Performance:
  Total duration:    5.25s
  Throughput:        190.33 qps

  Sample errors:
    - Finch was unable to provide a connection within the timeout due to excess queuin
    - Finch was unable to provide a connection within the timeout due to excess queuin
    - Finch was unable to provide a connection within the timeout due to excess queuin
.
Finished in 3914.1 seconds (3914.1s async, 0.00s sync)
10 tests, 0 failures
