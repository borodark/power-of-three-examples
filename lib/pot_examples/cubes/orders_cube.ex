defmodule Cubes.OrdersNoPreagg do
  @moduledoc """
  Ecto schema for querying the orders_no_preagg cube.
  Generated using PowerOfThree.CubeSchema.
  """

  use PowerOfThree.CubeSchema

  cube_schema :orders_no_preagg do
    # Dimensions
    dimension :brand_code, :string
    dimension :market_code, :string
    dimension :updated_at, :utc_datetime
    dimension :inserted_at, :utc_datetime

    # Measures
    measure :count, :integer
    measure :total_amount_sum, :float
    measure :tax_amount_sum, :float
    measure :subtotal_amount_sum, :float
    measure :customer_id_distinct, :integer
  end
end
