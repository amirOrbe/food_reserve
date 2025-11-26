defmodule FoodReserve.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset

  schema "orders" do
    # pending, confirmed, preparing, ready, completed, cancelled
    field :status, :string, default: "pending"
    field :special_instructions, :string
    field :total_amount, :decimal

    # Relaciones
    belongs_to :reservation, FoodReserve.Reservations.Reservation
    has_many :order_items, FoodReserve.Orders.OrderItem

    timestamps()
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [:status, :special_instructions, :total_amount, :reservation_id])
    |> validate_required([:status, :reservation_id])
    |> foreign_key_constraint(:reservation_id)
  end
end
