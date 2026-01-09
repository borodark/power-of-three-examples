  Created /home/io/projects/learn_erl/power-of-three-examples/test/saturation_test.exs with:

  Test Suites

  | Tag                       | Description                        |
  |---------------------------|------------------------------------|
  | --include saturation      | 100 concurrent tests + comparisons |
  | --include saturation_1000 | 1000 concurrent stress tests       |
  | --include live_cube       | All tests                          |

  Key Results

  Three-Way Comparison (mandata_captate, 100 concurrent, 512 variants):
  - Cold run:
    - Cube HTTP:     2412.93ms avg, 19.53 qps
    - ADBC Direct:     42.84ms avg, 58.65 qps
    - Phoenix/ADBC:  1616.9ms avg, 25.34 qps
  - Warm run:
    - Cube HTTP:     1416.77ms avg, 22.66 qps
    - ADBC Direct:     37.47ms avg, 63.61 qps
    - Phoenix/ADBC:  1102.71ms avg, 21.46 qps
  - Cache-off:
    - Cube HTTP:     1803.39ms avg, 20.35 qps
    - ADBC Direct:   3325.44ms avg, 19.58 qps
    - Phoenix/ADBC:  2307.94ms avg, 19.58 qps

  Variety (7 variants, 100 concurrent):
  - HTTP: 815.81ms avg, 94.7 qps (warm run)
  - ADBC:   6.81ms avg, 1515.15 qps (cold run); 9.19ms avg, 1449.28 qps (warm run)
  - Cache-off ADBC: 2385.95ms avg, 39.18 qps

  Mandata variety (512 variants, 100 concurrent):
  - ADBC:    38.95ms avg, 55.16 qps (cold run); 41.6ms avg, 62.66 qps (warm run)
  - Phoenix: 1839.58ms avg, 21.98 qps (warm run)
  - Cache-off ADBC: 25914.64ms avg, 1.93 qps
  - Cache-off Phoenix/ADBC: 2328.17ms avg, 18.07 qps

  High concurrency (mandata variety):
  - ADBC 1000: 419.67ms avg, 38.6 qps (cold run); 325.13ms avg, 40.0 qps (warm run)
  - ADBC 2000: 581.9ms avg, 37.32 qps (cold run); 502.02ms avg, 36.48 qps (warm run)
  - Cache-off ADBC 1000: 34057.56ms avg, 16.97 qps
  - Cache-off ADBC 2000: 46534.61ms avg, 22.3 qps

  Cache-off pre-aggregation vs no pre-aggregation (50 queries):
  - ADBC: Pre-Agg 1353.56ms avg, 36.1 qps; No Pre-Agg 1008.5ms avg, 47.21 qps (speedup 0.75x)
  - HTTP: Pre-Agg 994.84ms avg, 48.69 qps; No Pre-Agg 852.02ms avg, 57.54 qps (speedup 0.86x)

  Usage

  cd ~/projects/learn_erl/power-of-three-examples

  # Run all saturation tests
  mix test test/saturation_test.exs --include saturation

  # Include stress tests (1000 concurrent)
  mix test test/saturation_test.exs --include saturation --include saturation_1000
