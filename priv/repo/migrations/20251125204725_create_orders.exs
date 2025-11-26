defmodule FoodReserve.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :status, :string, null: false
      add :special_instructions, :text
      add :total_amount, :decimal, precision: 10, scale: 2
      add :reservation_id, references(:reservations, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:orders, [:reservation_id])

    create table(:order_items) do
      add :quantity, :integer, null: false
      add :price, :decimal, precision: 10, scale: 2, null: false
      add :notes, :text
      add :order_id, references(:orders, on_delete: :delete_all), null: false
      add :menu_item_id, references(:menu_items, on_delete: :nilify_all), null: false

      timestamps()
    end

    create index(:order_items, [:order_id])
    create index(:order_items, [:menu_item_id])
  end
end
