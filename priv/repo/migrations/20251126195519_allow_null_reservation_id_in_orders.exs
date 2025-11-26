defmodule FoodReserve.Repo.Migrations.AllowNullReservationIdInOrders do
  use Ecto.Migration

  def up do
    # Modificar la columna para permitir valores NULL usando SQL directo
    execute("ALTER TABLE orders ALTER COLUMN reservation_id DROP NOT NULL")
  end

  def down do
    # Restaurar la restricción NOT NULL
    execute("ALTER TABLE orders ALTER COLUMN reservation_id SET NOT NULL")
  end
end
