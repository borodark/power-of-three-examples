defmodule MagnaOrder do
  use Ecto.Schema

  @primary_key {:id, :id, autogenerate: false}

  schema "orders_no_preagg" do
    field(:brand_code, :string)
    field(:market_code, :string)
    field(:updated_at, :utc_datetime)
    field(:inserted_at, :utc_datetime)
    ## Measures
    field(:count, :integer)
    field(:total_amount_sum, :integer)
    field(:tax_amount_sum, :integer)
    field(:subtotal_amount_sum, :integer)
    field(:customer_id_distinct, :integer)
  end
end
