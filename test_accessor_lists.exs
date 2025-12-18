#!/usr/bin/env elixir

# Test that dimensions() and measures() return lists of structs

Mix.install([
  {:power_of_3, path: "../power-of-three"}
])

IO.puts("\n=== Testing Accessor Lists ===\n")

# Ensure PowerOfThree modules are loaded
Code.ensure_loaded!(PowerOfThree.DimensionRef)
Code.ensure_loaded!(PowerOfThree.MeasureRef)

# Load the Customer module
Code.require_file("lib/pot_examples/customer.ex", __DIR__)

alias PotExamples.Customer
alias PowerOfThree.DimensionRef
alias PowerOfThree.MeasureRef

# Test 1: Check that dimensions() returns a list
IO.puts("Test 1: Customer.dimensions() returns a list")
dimensions = Customer.dimensions()
IO.puts("  Type: #{inspect(is_list(dimensions))}")
IO.puts("  Count: #{length(dimensions)}")
IO.puts("")

# Test 2: Check that all dimension items are DimensionRef structs
IO.puts("Test 2: All items are %DimensionRef{}")
all_dimension_refs = Enum.all?(dimensions, fn d ->
  match?(%DimensionRef{}, d)
end)
IO.puts("  All are DimensionRef: #{all_dimension_refs}")

if all_dimension_refs do
  IO.puts("  ✓ All dimension items are properly resolved structs")
else
  IO.puts("  ✗ Some items are not DimensionRef structs")
  exit(:invalid_dimension_structs)
end
IO.puts("")

# Test 3: Print all dimensions
IO.puts("Test 3: List all dimensions")
Enum.each(dimensions, fn dim ->
  IO.puts("  - #{dim.name} (#{dim.type})")
end)
IO.puts("")

# Test 4: Check that measures() returns a list
IO.puts("Test 4: Customer.measures() returns a list")
measures = Customer.measures()
IO.puts("  Type: #{inspect(is_list(measures))}")
IO.puts("  Count: #{length(measures)}")
IO.puts("")

# Test 5: Check that all measure items are MeasureRef structs
IO.puts("Test 5: All items are %MeasureRef{}")
all_measure_refs = Enum.all?(measures, fn m ->
  match?(%MeasureRef{}, m)
end)
IO.puts("  All are MeasureRef: #{all_measure_refs}")

if all_measure_refs do
  IO.puts("  ✓ All measure items are properly resolved structs")
else
  IO.puts("  ✗ Some items are not MeasureRef structs")
  exit(:invalid_measure_structs)
end
IO.puts("")

# Test 6: Print all measures
IO.puts("Test 6: List all measures")
Enum.each(measures, fn meas ->
  IO.puts("  - #{meas.name} (#{meas.type})")
end)
IO.puts("")

# Test 7: Verify we can still use the accessor modules directly
IO.puts("Test 7: Direct accessor functions still work")
brand_dim = Customer.Dimensions.brand()
count_measure = Customer.Measures.count()

unless match?(%DimensionRef{}, brand_dim) do
  IO.puts("  ✗ Direct dimension accessor failed")
  exit(:direct_dimension_accessor_failed)
end

unless match?(%MeasureRef{}, count_measure) do
  IO.puts("  ✗ Direct measure accessor failed")
  exit(:direct_measure_accessor_failed)
end

IO.puts("  ✓ Direct accessors still work correctly")
IO.puts("  Brand: #{inspect(brand_dim.name)}")
IO.puts("  Count: #{inspect(count_measure.name)}")
IO.puts("")

IO.puts("=== All Tests Passed! ===\n")
