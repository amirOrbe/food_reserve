defmodule FoodReserve.Repo.Migrations.AddRestaurantIdToOrders do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :restaurant_id, references(:restaurants, on_delete: :nothing)
    end

    create index(:orders, [:restaurant_id])
  end
end
