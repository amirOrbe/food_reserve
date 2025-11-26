defmodule FoodReserve.Repo.Migrations.AddPickupFieldsToOrders do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      # dine_in, pickup
      add :order_type, :string, default: "dine_in", null: false
      add :pickup_time, :time
      add :pickup_date, :date
      add :pickup_name, :string
      add :pickup_phone, :string
    end

    create index(:orders, [:order_type])
  end
end
