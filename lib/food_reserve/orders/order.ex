defmodule FoodReserve.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset

  schema "orders" do
    # pending, confirmed, preparing, ready, completed, cancelled
    field :status, :string, default: "pending"
    field :special_instructions, :string
    field :total_amount, :decimal

    # Tipo de orden: dine_in (reservación en restaurante) o pickup (para llevar)
    field :order_type, :string, default: "dine_in"

    # Campos específicos para pedidos para llevar (pickup)
    field :pickup_time, :time
    field :pickup_date, :date
    field :pickup_name, :string
    field :pickup_phone, :string

    # Relaciones
    belongs_to :reservation, FoodReserve.Reservations.Reservation
    belongs_to :restaurant, FoodReserve.Restaurants.Restaurant
    belongs_to :user, FoodReserve.Accounts.User
    has_many :order_items, FoodReserve.Orders.OrderItem

    timestamps()
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [
      :status,
      :special_instructions,
      :total_amount,
      :reservation_id,
      :restaurant_id,
      :user_id,
      :order_type,
      :pickup_time,
      :pickup_date,
      :pickup_name,
      :pickup_phone
    ])
    |> validate_required([:status, :order_type])
    |> validate_order_type()
    |> foreign_key_constraint(:reservation_id)
  end

  defp validate_order_type(changeset) do
    order_type = get_field(changeset, :order_type)

    case order_type do
      "dine_in" ->
        # Para pedidos en restaurante, se requiere reservation_id
        changeset
        |> validate_required([:reservation_id])

      "pickup" ->
        # Para pedidos para llevar, se requieren los campos de pickup pero NO reservation_id
        changeset
        |> validate_required([
          :pickup_name,
          :pickup_phone,
          :pickup_time,
          :pickup_date,
          :restaurant_id
        ])
        |> validate_pickup_date()
        |> validate_format(:pickup_phone, ~r/^\d{10}$/,
          message: "debe ser un número de teléfono válido de 10 dígitos"
        )
        # Asegurar que reservation_id es NULL para pedidos para llevar
        |> put_change(:reservation_id, nil)

      _ ->
        add_error(changeset, :order_type, "tipo de orden inválido, debe ser 'dine_in' o 'pickup'")
    end
  end

  defp validate_pickup_date(changeset) do
    pickup_date = get_field(changeset, :pickup_date)

    # Usar fecha local en vez de UTC
    local_today = local_today()

    if pickup_date && Date.compare(pickup_date, local_today) != :lt do
      # La fecha es hoy o en el futuro, lo cual es válido
      if Date.compare(pickup_date, local_today) != :eq do
        # Si no es para hoy, añadir un error
        add_error(
          changeset,
          :pickup_date,
          "los pedidos para llevar solo pueden ser para el día de hoy"
        )
      else
        changeset
      end
    else
      # La fecha es en el pasado
      add_error(changeset, :pickup_date, "no se puede seleccionar una fecha pasada")
    end
  end

  # Función auxiliar para obtener la fecha actual en la zona horaria de México (GMT-6)
  defp local_today() do
    utc_datetime = DateTime.utc_now()
    # Restamos 6 horas para GMT-6
    local_datetime = DateTime.add(utc_datetime, -6 * 60 * 60, :second)
    DateTime.to_date(local_datetime)
  end

  # Esta función ya no es necesaria porque estamos usando validate_format
  # para validar el formato del teléfono directamente en validate_order_type
end
