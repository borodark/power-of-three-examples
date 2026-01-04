  Created /home/io/projects/learn_erl/power-of-three-examples/test/saturation_test.exs with:

  Test Suites

  | Tag                       | Description                        |
  |---------------------------|------------------------------------|
  | --include saturation      | 100 concurrent tests + comparisons |
  | --include saturation_1000 | 1000 concurrent stress tests       |
  | --include live_cube       | All tests                          |

  Key Results

  Pre-Aggregation Impact (ADBC):
  With Pre-Agg:    2.48ms avg,  10,000 qps
  No Pre-Agg:   2,317ms avg,      22 qps
  Speedup: 934x faster

  HTTP vs ADBC (with pre-agg):
  HTTP:   428ms avg,    167 qps
  ADBC:     4ms avg, 12,500 qps
  ADBC is ~100x faster

  Usage

  cd ~/projects/learn_erl/power-of-three-examples

  # Run all saturation tests
  mix test test/saturation_test.exs --include saturation

  # Include stress tests (1000 concurrent)
  mix test test/saturation_test.exs --include saturation --include saturation_1000

