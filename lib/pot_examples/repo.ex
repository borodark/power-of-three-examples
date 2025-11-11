defmodule Postgres.Repo do
  @moduledoc false
  use Ecto.Repo,
    otp_app: :pot_examples,
    adapter: Ecto.Adapters.Postgres
end
