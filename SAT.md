  Created /home/io/projects/learn_erl/power-of-three-examples/test/saturation_test.exs with:

  Test Suites

  | Tag                       | Description                        |
  |---------------------------|------------------------------------|
  | --include saturation      | 100 concurrent tests + comparisons |
  | --include saturation_1000 | 1000 concurrent stress tests       |
  | --include live_cube       | All tests                          |

  Key Results

  Three-Way Comparison (mandata_captate, 100 concurrent, 512 variants):
  - Cube HTTP:     2958.97ms avg, 13.06 qps
  - ADBC Direct:     42.74ms avg, 63.69 qps
  - Phoenix/ADBC:  1346.18ms avg, 24.15 qps

  Variety (7 variants, 100 concurrent):
  - HTTP: 1051.36ms avg, 74.29 qps
  - ADBC:   38.73ms avg, 757.58 qps

  Mandata variety (512 variants, 100 concurrent):
  - ADBC:    38.58ms avg, 65.7 qps
  - Phoenix: 1419.59ms avg, 21.3 qps

  High concurrency (mandata variety):
  - ADBC 1000: 284.81ms avg, 41.83 qps
  - ADBC 2000: 587.45ms avg, 38.4 qps

  Usage

  cd ~/projects/learn_erl/power-of-three-examples

  # Run all saturation tests
  mix test test/saturation_test.exs --include saturation

  # Include stress tests (1000 concurrent)
  mix test test/saturation_test.exs --include saturation --include saturation_1000
