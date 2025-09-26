defmodule FoodReserve.Repo do
  use Ecto.Repo,
    otp_app: :food_reserve,
    adapter: Ecto.Adapters.Postgres
end
