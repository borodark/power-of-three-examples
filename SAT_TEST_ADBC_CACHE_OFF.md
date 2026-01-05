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


[2 min elapsed, 27 min remaining] HTTP Endurance
├─ Requests: 19851 total (19795 ok, 56 failed)
├─ Success Rate: 99.72%
├─ Throughput: 165.42 qps
├─ Latency: avg=4816.17ms, p50=4794ms, p95=5122ms, p99=5215ms
└─ Std Dev: 181.82ms


[3 min elapsed, 26 min remaining] HTTP Endurance
├─ Requests: 29802 total (29516 ok, 286 failed)
├─ Success Rate: 99.04%
├─ Throughput: 165.56 qps
├─ Latency: avg=4828.43ms, p50=4793ms, p95=5166ms, p99=5416ms
└─ Std Dev: 215.69ms


[4 min elapsed, 25 min remaining] HTTP Endurance
├─ Requests: 39678 total (39288 ok, 390 failed)
├─ Success Rate: 99.02%
├─ Throughput: 165.31 qps
├─ Latency: avg=4843.91ms, p50=4850ms, p95=5237ms, p99=5301ms
└─ Std Dev: 211.98ms


[5 min elapsed, 24 min remaining] HTTP Endurance
├─ Requests: 49508 total (49036 ok, 472 failed)
├─ Success Rate: 99.05%
├─ Throughput: 165.01 qps
├─ Latency: avg=4844.89ms, p50=4846ms, p95=5241ms, p99=5325ms
└─ Std Dev: 210.99ms


[6 min elapsed, 23 min remaining] HTTP Endurance
├─ Requests: 59234 total (58636 ok, 598 failed)
├─ Success Rate: 98.99%
├─ Throughput: 164.52 qps
├─ Latency: avg=4909.33ms, p50=4881ms, p95=5247ms, p99=5301ms
└─ Std Dev: 194.83ms


[7 min elapsed, 22 min remaining] HTTP Endurance
├─ Requests: 69122 total (68519 ok, 603 failed)
├─ Success Rate: 99.13%
├─ Throughput: 164.56 qps
├─ Latency: avg=4833.16ms, p50=4828ms, p95=5157ms, p99=5250ms
└─ Std Dev: 158.07ms


[8 min elapsed, 21 min remaining] HTTP Endurance
├─ Requests: 78927 total (78219 ok, 708 failed)
├─ Success Rate: 99.1%
├─ Throughput: 164.42 qps
├─ Latency: avg=4885.97ms, p50=4837ms, p95=5222ms, p99=5292ms
└─ Std Dev: 207.48ms


[9 min elapsed, 20 min remaining] HTTP Endurance
├─ Requests: 88734 total (87971 ok, 763 failed)
├─ Success Rate: 99.14%
├─ Throughput: 164.31 qps
├─ Latency: avg=4872.2ms, p50=4859ms, p95=5225ms, p99=5298ms
└─ Std Dev: 238.3ms


[10 min elapsed, 19 min remaining] HTTP Endurance
├─ Requests: 98537 total (97719 ok, 818 failed)
├─ Success Rate: 99.17%
├─ Throughput: 164.21 qps
├─ Latency: avg=4883.15ms, p50=4845ms, p95=5235ms, p99=5298ms
└─ Std Dev: 207.12ms


[11 min elapsed, 18 min remaining] HTTP Endurance
├─ Requests: 108530 total (107712 ok, 818 failed)
├─ Success Rate: 99.25%
├─ Throughput: 164.42 qps
├─ Latency: avg=4800.74ms, p50=4778ms, p95=5155ms, p99=5191ms
└─ Std Dev: 178.05ms


[12 min elapsed, 17 min remaining] HTTP Endurance
├─ Requests: 118534 total (117716 ok, 818 failed)
├─ Success Rate: 99.31%
├─ Throughput: 164.62 qps
├─ Latency: avg=4777.85ms, p50=4767ms, p95=4995ms, p99=5137ms
└─ Std Dev: 139.48ms


[13 min elapsed, 16 min remaining] HTTP Endurance
├─ Requests: 128326 total (127403 ok, 923 failed)
├─ Success Rate: 99.28%
├─ Throughput: 164.51 qps
├─ Latency: avg=4872.28ms, p50=4868ms, p95=5269ms, p99=5331ms
└─ Std Dev: 237.29ms


[14 min elapsed, 15 min remaining] HTTP Endurance
├─ Requests: 138155 total (137132 ok, 1023 failed)
├─ Success Rate: 99.26%
├─ Throughput: 164.46 qps
├─ Latency: avg=4852.51ms, p50=4823ms, p95=5225ms, p99=5298ms
└─ Std Dev: 204.18ms


[15 min elapsed, 14 min remaining] HTTP Endurance
├─ Requests: 148222 total (147199 ok, 1023 failed)
├─ Success Rate: 99.31%
├─ Throughput: 164.67 qps
├─ Latency: avg=4738.53ms, p50=4688ms, p95=5197ms, p99=5248ms
└─ Std Dev: 170.96ms


[16 min elapsed, 13 min remaining] HTTP Endurance
├─ Requests: 157765 total (156573 ok, 1192 failed)
├─ Success Rate: 99.24%
├─ Throughput: 164.32 qps
├─ Latency: avg=5011.95ms, p50=5014ms, p95=5292ms, p99=5341ms
└─ Std Dev: 187.27ms


[17 min elapsed, 12 min remaining] HTTP Endurance
├─ Requests: 167562 total (166202 ok, 1360 failed)
├─ Success Rate: 99.19%
├─ Throughput: 164.26 qps
├─ Latency: avg=4904.38ms, p50=4820ms, p95=5278ms, p99=5339ms
└─ Std Dev: 233.75ms


[18 min elapsed, 11 min remaining] HTTP Endurance
├─ Requests: 177349 total (175989 ok, 1360 failed)
├─ Success Rate: 99.23%
├─ Throughput: 164.2 qps
├─ Latency: avg=4886.08ms, p50=4873ms, p95=5200ms, p99=5266ms
└─ Std Dev: 180.44ms


[19 min elapsed, 10 min remaining] HTTP Endurance
├─ Requests: 186986 total (185461 ok, 1525 failed)
├─ Success Rate: 99.18%
├─ Throughput: 164.01 qps
├─ Latency: avg=4959.21ms, p50=4972ms, p95=5276ms, p99=5321ms
└─ Std Dev: 212.05ms


[20 min elapsed, 9 min remaining] HTTP Endurance
├─ Requests: 196737 total (195027 ok, 1710 failed)
├─ Success Rate: 99.13%
├─ Throughput: 163.93 qps
├─ Latency: avg=4904.77ms, p50=4894ms, p95=5282ms, p99=5366ms
└─ Std Dev: 260.77ms


[21 min elapsed, 8 min remaining] HTTP Endurance
├─ Requests: 206445 total (204628 ok, 1817 failed)
├─ Success Rate: 99.12%
├─ Throughput: 163.83 qps
├─ Latency: avg=4929.92ms, p50=4921ms, p95=5301ms, p99=5336ms
└─ Std Dev: 237.17ms


[22 min elapsed, 7 min remaining] HTTP Endurance
├─ Requests: 216089 total (214154 ok, 1935 failed)
├─ Success Rate: 99.1%
├─ Throughput: 163.69 qps
├─ Latency: avg=4960.54ms, p50=5039ms, p95=5270ms, p99=5327ms
└─ Std Dev: 255.78ms


[23 min elapsed, 6 min remaining] HTTP Endurance
├─ Requests: 225883 total (223897 ok, 1986 failed)
├─ Success Rate: 99.12%
├─ Throughput: 163.67 qps
├─ Latency: avg=4899.03ms, p50=4892ms, p95=5148ms, p99=5274ms
└─ Std Dev: 163.25ms


[24 min elapsed, 5 min remaining] HTTP Endurance
├─ Requests: 235651 total (233615 ok, 2036 failed)
├─ Success Rate: 99.14%
├─ Throughput: 163.63 qps
├─ Latency: avg=4909.01ms, p50=4905ms, p95=5194ms, p99=5250ms
└─ Std Dev: 180.28ms


[25 min elapsed, 4 min remaining] HTTP Endurance
├─ Requests: 245674 total (243638 ok, 2036 failed)
├─ Success Rate: 99.17%
├─ Throughput: 163.77 qps
├─ Latency: avg=4764.18ms, p50=4761ms, p95=5086ms, p99=5170ms
└─ Std Dev: 165.97ms


[26 min elapsed, 3 min remaining] HTTP Endurance
├─ Requests: 255403 total (253299 ok, 2104 failed)
├─ Success Rate: 99.18%
├─ Throughput: 163.71 qps
├─ Latency: avg=4909.16ms, p50=4874ms, p95=5227ms, p99=5302ms
└─ Std Dev: 174.75ms


[27 min elapsed, 2 min remaining] HTTP Endurance
├─ Requests: 265448 total (263344 ok, 2104 failed)
├─ Success Rate: 99.21%
├─ Throughput: 163.84 qps
├─ Latency: avg=4776.05ms, p50=4750ms, p95=5051ms, p99=5172ms
└─ Std Dev: 150.71ms


[28 min elapsed, 1 min remaining] HTTP Endurance
├─ Requests: 275339 total (273184 ok, 2155 failed)
├─ Success Rate: 99.22%
├─ Throughput: 163.88 qps
├─ Latency: avg=4834.48ms, p50=4805ms, p95=5145ms, p99=5204ms
└─ Std Dev: 184.55ms


[29 min elapsed, 0 min remaining] HTTP Endurance
├─ Requests: 285228 total (282981 ok, 2247 failed)
├─ Success Rate: 99.21%
├─ Throughput: 163.91 qps
├─ Latency: avg=4801.35ms, p50=4768ms, p95=5201ms, p99=5298ms
└─ Std Dev: 189.96ms


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


[2 min elapsed, 2 min remaining] ADBC Quick Endurance
├─ Requests: 6018 total (6018 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 50.08 qps
├─ Latency: avg=1965.69ms, p50=1965ms, p95=2703ms, p99=3038ms
└─ Std Dev: 435.58ms


[3 min elapsed, 1 min remaining] ADBC Quick Endurance
├─ Requests: 8972 total (8972 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 49.79 qps
├─ Latency: avg=1984.73ms, p50=1968ms, p95=2856ms, p99=3277ms
└─ Std Dev: 488.08ms


[4 min elapsed, 0 min remaining] ADBC Quick Endurance
├─ Requests: 12059 total (12059 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 50.18 qps
├─ Latency: avg=1982.53ms, p50=1949ms, p95=2958ms, p99=3354ms
└─ Std Dev: 538.15ms


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


[2 min elapsed, 27 min remaining] ADBC Endurance
├─ Requests: 5964 total (5964 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 49.63 qps
├─ Latency: avg=15050.34ms, p50=15974ms, p95=17169ms, p99=17508ms
└─ Std Dev: 3158.05ms


[3 min elapsed, 26 min remaining] ADBC Endurance
├─ Requests: 9128 total (9128 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 50.62 qps
├─ Latency: avg=15136.97ms, p50=15727ms, p95=17037ms, p99=17438ms
└─ Std Dev: 2590.75ms


[4 min elapsed, 25 min remaining] ADBC Endurance
├─ Requests: 12225 total (12225 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 50.81 qps
├─ Latency: avg=15702.82ms, p50=15762ms, p95=17026ms, p99=17403ms
└─ Std Dev: 858.07ms


[5 min elapsed, 24 min remaining] ADBC Endurance
├─ Requests: 15318 total (15318 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 50.9 qps
├─ Latency: avg=15540.13ms, p50=15602ms, p95=16905ms, p99=17333ms
└─ Std Dev: 869.86ms


[6 min elapsed, 23 min remaining] ADBC Endurance
├─ Requests: 18419 total (18419 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 51.02 qps
├─ Latency: avg=15510.65ms, p50=15567ms, p95=16934ms, p99=17452ms
└─ Std Dev: 932.62ms


[7 min elapsed, 22 min remaining] ADBC Endurance
├─ Requests: 21494 total (21494 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 51.05 qps
├─ Latency: avg=15521.79ms, p50=15605ms, p95=16994ms, p99=17869ms
└─ Std Dev: 1000.47ms


[8 min elapsed, 21 min remaining] ADBC Endurance
├─ Requests: 24597 total (24597 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 51.13 qps
├─ Latency: avg=15494.42ms, p50=15611ms, p95=17052ms, p99=18345ms
└─ Std Dev: 1077.64ms


[9 min elapsed, 20 min remaining] ADBC Endurance
├─ Requests: 27887 total (27887 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 51.53 qps
├─ Latency: avg=15338.14ms, p50=15531ms, p95=17120ms, p99=18508ms
└─ Std Dev: 1289.11ms


[10 min elapsed, 19 min remaining] ADBC Endurance
├─ Requests: 31494 total (31494 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 52.38 qps
├─ Latency: avg=14490.76ms, p50=14396ms, p95=16892ms, p99=18375ms
└─ Std Dev: 1606.79ms


[11 min elapsed, 18 min remaining] ADBC Endurance
├─ Requests: 34732 total (34732 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 52.51 qps
├─ Latency: avg=14215.15ms, p50=14107ms, p95=16783ms, p99=17943ms
└─ Std Dev: 1530.02ms


[12 min elapsed, 17 min remaining] ADBC Endurance
├─ Requests: 37821 total (37821 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 52.42 qps
├─ Latency: avg=14401.06ms, p50=14242ms, p95=17132ms, p99=18348ms
└─ Std Dev: 1604.39ms


[13 min elapsed, 16 min remaining] ADBC Endurance
├─ Requests: 40862 total (40862 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 52.28 qps
├─ Latency: avg=15149.12ms, p50=15196ms, p95=17663ms, p99=18795ms
└─ Std Dev: 1521.5ms


[14 min elapsed, 15 min remaining] ADBC Endurance
├─ Requests: 43912 total (43912 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 52.17 qps
├─ Latency: avg=15706.96ms, p50=15819ms, p95=17991ms, p99=18978ms
└─ Std Dev: 1370.78ms


[15 min elapsed, 14 min remaining] ADBC Endurance
├─ Requests: 47000 total (47000 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 52.11 qps
├─ Latency: avg=15657.82ms, p50=15789ms, p95=17957ms, p99=18896ms
└─ Std Dev: 1369.3ms


[16 min elapsed, 13 min remaining] ADBC Endurance
├─ Requests: 50069 total (50069 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 52.04 qps
├─ Latency: avg=15690.65ms, p50=15789ms, p95=17992ms, p99=18978ms
└─ Std Dev: 1386.57ms


[17 min elapsed, 12 min remaining] ADBC Endurance
├─ Requests: 53148 total (53148 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 51.99 qps
├─ Latency: avg=15593.95ms, p50=15677ms, p95=17818ms, p99=18931ms
└─ Std Dev: 1375.19ms


[18 min elapsed, 11 min remaining] ADBC Endurance
├─ Requests: 56183 total (56183 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 51.91 qps
├─ Latency: avg=15701.49ms, p50=15778ms, p95=17949ms, p99=19151ms
└─ Std Dev: 1385.46ms


[19 min elapsed, 10 min remaining] ADBC Endurance
├─ Requests: 59252 total (59252 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 51.86 qps
├─ Latency: avg=15679.79ms, p50=15769ms, p95=18009ms, p99=19138ms
└─ Std Dev: 1412.8ms


[20 min elapsed, 9 min remaining] ADBC Endurance
├─ Requests: 62331 total (62331 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 51.82 qps
├─ Latency: avg=15673.87ms, p50=15776ms, p95=18068ms, p99=19045ms
└─ Std Dev: 1445.46ms


[21 min elapsed, 8 min remaining] ADBC Endurance
├─ Requests: 65384 total (65384 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 51.78 qps
├─ Latency: avg=15696.41ms, p50=15811ms, p95=18169ms, p99=19018ms
└─ Std Dev: 1492.35ms


[22 min elapsed, 7 min remaining] ADBC Endurance
├─ Requests: 68448 total (68448 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 51.74 qps
├─ Latency: avg=15664.26ms, p50=15774ms, p95=18223ms, p99=18952ms
└─ Std Dev: 1527.29ms


[23 min elapsed, 6 min remaining] ADBC Endurance
├─ Requests: 71488 total (71488 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 51.69 qps
├─ Latency: avg=15727.89ms, p50=15812ms, p95=18383ms, p99=19056ms
└─ Std Dev: 1579.69ms


[24 min elapsed, 5 min remaining] ADBC Endurance
├─ Requests: 74587 total (74587 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 51.69 qps
├─ Latency: avg=15730.01ms, p50=15787ms, p95=18453ms, p99=19133ms
└─ Std Dev: 1608.91ms


[25 min elapsed, 4 min remaining] ADBC Endurance
├─ Requests: 77626 total (77626 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 51.63 qps
├─ Latency: avg=15753.76ms, p50=15768ms, p95=18526ms, p99=19278ms
└─ Std Dev: 1624.31ms


[26 min elapsed, 3 min remaining] ADBC Endurance
├─ Requests: 80667 total (80667 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 51.59 qps
├─ Latency: avg=15808.31ms, p50=15813ms, p95=18657ms, p99=19389ms
└─ Std Dev: 1658.0ms


[27 min elapsed, 2 min remaining] ADBC Endurance
├─ Requests: 83730 total (83730 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 51.56 qps
├─ Latency: avg=15763.87ms, p50=15757ms, p95=18557ms, p99=19278ms
└─ Std Dev: 1635.98ms


[28 min elapsed, 1 min remaining] ADBC Endurance
├─ Requests: 86760 total (86760 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 51.52 qps
├─ Latency: avg=15805.73ms, p50=15816ms, p95=18575ms, p99=19184ms
└─ Std Dev: 1603.64ms


[29 min elapsed, 0 min remaining] ADBC Endurance
├─ Requests: 89758 total (89758 ok, 0 failed)
├─ Success Rate: 100.0%
├─ Throughput: 51.46 qps
├─ Latency: avg=15818.02ms, p50=15851ms, p95=18508ms, p99=19114ms
└─ Std Dev: 1565.94ms


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
