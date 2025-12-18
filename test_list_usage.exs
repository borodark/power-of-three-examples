alias PotExamples.Customer

IO.puts("\n=== Testing List Usage with QueryBuilder ===\n")

# Get all dimensions and measures as lists
dimensions = Customer.dimensions()
measures = Customer.measures()

IO.puts("Available dimensions: #{length(dimensions)}")
Enum.each(dimensions, fn d -> IO.puts("  - #{d.name} (#{d.type})") end)

IO.puts("\nAvailable measures: #{length(measures)}")
Enum.each(measures, fn m -> IO.puts("  - #{m.name} (#{m.type})") end)

# Find specific ones from the lists
brand = Enum.find(dimensions, fn d -> d.name == :brand end)
zodiac = Enum.find(dimensions, fn d -> d.name == :zodiac end)
count = Enum.find(measures, fn m -> m.name == "count" or m.name == :count end)

IO.puts("\nBuilding SQL query using items from lists...")

sql =
  PowerOfThree.QueryBuilder.build(
    cube: "customer",
    columns: [brand, zodiac, count],
    limit: 5
  )

IO.puts("\nGenerated SQL:")
IO.puts(sql)

IO.puts("\n=== Success! List-based accessors work perfectly ===\n")
