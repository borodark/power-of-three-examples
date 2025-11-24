defmodule PotExamples.OrdersCube do
  @moduledoc false

  use Ecto.Schema

  @type t() :: %__MODULE__{}

  schema "orders" do
    field(:order_id, :integer, primary_key: true)
    field(:FIN)
    field(:FUL)
    field(:market_code)
    field(:brand)
    field(:subtotal_amount, :decimal)
    field(:tax_amount, :decimal)
    field(:total_amount, :float)
    field(:discount_total_amount, :float)
    field(:discount_and_tax, :float)
    field(:count, :integer)
  end
end
