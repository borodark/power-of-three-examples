defmodule PotExamples.AccessorListTest do
  use ExUnit.Case, async: true

  alias PotExamples.Customer
  alias PowerOfThree.DimensionRef
  alias PowerOfThree.MeasureRef

  describe "Customer.dimensions/0" do
    test "returns a list" do
      result = Customer.dimensions()
      assert is_list(result)
    end

    test "all items are DimensionRef structs" do
      dimensions = Customer.dimensions()

      Enum.each(dimensions, fn dim ->
        assert %DimensionRef{} = dim
        assert dim.name != nil
        assert dim.module == Customer
        assert dim.type != nil
      end)
    end

    test "returns all defined dimensions" do
      dimensions = Customer.dimensions()

      # Should have at least these dimensions
      names = Enum.map(dimensions, & &1.name)

      assert :brand in names
      assert :market in names
      assert :email_per_brand_per_market in names
      assert :zodiac in names
    end

    test "each dimension has complete metadata" do
      dimensions = Customer.dimensions()

      Enum.each(dimensions, fn dim ->
        # Each dimension should have required fields
        assert is_atom(dim.name) or is_binary(dim.name)
        assert dim.module == Customer
        assert dim.type in [:string, :number, :time, :boolean, :geo]
        assert dim.sql != nil
      end)
    end
  end

  describe "Customer.measures/0" do
    test "returns a list" do
      result = Customer.measures()
      assert is_list(result)
    end

    test "all items are MeasureRef structs" do
      measures = Customer.measures()

      Enum.each(measures, fn meas ->
        assert %MeasureRef{} = meas
        assert meas.name != nil
        assert meas.module == Customer
        assert meas.type != nil
      end)
    end

    test "returns all defined measures" do
      measures = Customer.measures()

      # Should have at least these measures
      names = Enum.map(measures, & &1.name)

      assert "count" in names or :count in names
      assert :emails_distinct in names or "emails_distinct" in names
      assert :aquarii in names or "aquarii" in names
    end

    test "each measure has complete metadata" do
      measures = Customer.measures()

      Enum.each(measures, fn meas ->
        # Each measure should have required fields
        assert is_atom(meas.name) or is_binary(meas.name)
        assert meas.module == Customer

        assert meas.type in [
                 :count,
                 :count_distinct,
                 :count_distinct_approx,
                 :sum,
                 :avg,
                 :min,
                 :max,
                 :number
               ]
      end)
    end
  end

  describe "Direct accessor modules still work" do
    test "Customer.Dimensions module has individual accessors" do
      # Can still call individual dimension accessors
      assert %DimensionRef{} = Customer.Dimensions.brand()
      assert %DimensionRef{} = Customer.Dimensions.market()
      assert %DimensionRef{} = Customer.Dimensions.zodiac()
    end

    test "Customer.Measures module has individual accessors" do
      # Can still call individual measure accessors
      assert %MeasureRef{} = Customer.Measures.count()
      assert %MeasureRef{} = Customer.Measures.emails_distinct()
      assert %MeasureRef{} = Customer.Measures.aquarii()
    end

    test "individual accessors return same structs as list accessors" do
      dimensions = Customer.dimensions()
      brand_from_list = Enum.find(dimensions, fn d -> d.name == :brand end)
      brand_from_accessor = Customer.Dimensions.brand()

      assert brand_from_list == brand_from_accessor

      measures = Customer.measures()
      count_from_list = Enum.find(measures, fn m -> m.name == "count" or m.name == :count end)
      count_from_accessor = Customer.Measures.count()

      assert count_from_list == count_from_accessor
    end
  end

  describe "Integration with QueryBuilder" do
    test "can use dimensions from list in QueryBuilder" do
      dimensions = Customer.dimensions()
      brand = Enum.find(dimensions, fn d -> d.name == :brand end)

      assert brand != nil

      # Should be usable in QueryBuilder
      sql =
        PowerOfThree.QueryBuilder.build(
          cube: "customer",
          columns: [brand],
          limit: 1
        )

      assert sql =~ "customer.brand"
    end

    test "can use measures from list in QueryBuilder" do
      measures = Customer.measures()
      count = Enum.find(measures, fn m -> m.name == "count" or m.name == :count end)

      assert count != nil

      # Should be usable in QueryBuilder
      sql =
        PowerOfThree.QueryBuilder.build(
          cube: "customer",
          columns: [count],
          limit: 1
        )

      assert sql =~ "MEASURE(customer.count)"
    end

    test "can mix dimensions and measures from lists" do
      dimensions = Customer.dimensions()
      measures = Customer.measures()

      brand = Enum.find(dimensions, fn d -> d.name == :brand end)
      zodiac = Enum.find(dimensions, fn d -> d.name == :zodiac end)
      count = Enum.find(measures, fn m -> m.name == "count" or m.name == :count end)

      sql =
        PowerOfThree.QueryBuilder.build(
          cube: "customer",
          columns: [brand, zodiac, count],
          limit: 5
        )

      assert sql =~ "customer.brand"
      assert sql =~ "customer.zodiac"
      assert sql =~ "MEASURE(customer.count)"
      assert sql =~ "GROUP BY 1, 2"
      assert sql =~ "LIMIT 5"
    end
  end
end
