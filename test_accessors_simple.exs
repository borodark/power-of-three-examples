alias PotExamples.Customer

IO.puts("\n=== Testing Accessor Functions ===\n")

IO.puts("Testing dimensions()...")
dimensions = Customer.dimensions()
IO.puts("  Type: #{inspect(is_list(dimensions))}")
IO.puts("  Count: #{length(dimensions)}")

if dimensions != [] do
  first = hd(dimensions)

  IO.puts(
    "  First item: %#{inspect(first.__struct__)}{name: #{inspect(first.name)}, type: #{inspect(first.type)}}"
  )
end

IO.puts("\nTesting measures()...")
measures = Customer.measures()
IO.puts("  Type: #{inspect(is_list(measures))}")
IO.puts("  Count: #{length(measures)}")

if measures != [] do
  first = hd(measures)

  IO.puts(
    "  First item: %#{inspect(first.__struct__)}{name: #{inspect(first.name)}, type: #{inspect(first.type)}}"
  )
end

IO.puts("\n=== Success! ===\n")
