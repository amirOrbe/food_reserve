defmodule FoodReserve.Orders.OrderItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "order_items" do
    field :quantity, :integer
    field :price, :decimal
    field :notes, :string

    # Relaciones
    belongs_to :order, FoodReserve.Orders.Order
    belongs_to :menu_item, FoodReserve.Menus.MenuItem

    timestamps()
  end

  @doc false
  def changeset(order_item, attrs) do
    order_item
    |> cast(attrs, [:quantity, :price, :notes, :order_id, :menu_item_id])
    |> validate_required([:quantity, :price, :order_id, :menu_item_id])
    |> validate_number(:quantity, greater_than: 0)
    |> foreign_key_constraint(:order_id)
    |> foreign_key_constraint(:menu_item_id)
  end
end
