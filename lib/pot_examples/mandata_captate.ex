defmodule MagnaOrder do
  use Ecto.Schema
  schema "public.order" do
    field(:delivery_subtotal_amount, :integer)
    field(:discount_total_amount, :integer)
    field(:email, :string)
    field(:financial_status, :string)
    field(:fulfillment_status, :string)
    field(:payment_reference, :string)
    field(:subtotal_amount, :integer)
    field(:tax_amount, :integer)
    field(:total_amount, :integer)
    field(:brand_code, :string)
    field(:market_code, :string)
    field(:customer_id, :integer)
    timestamps()
  end
end
