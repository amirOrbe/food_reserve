defmodule FoodReserve.Reservations.Reservation do
  use Ecto.Schema
  import Ecto.Changeset

  @statuses ["pending", "confirmed", "cancelled", "completed"]

  schema "reservations" do
    field :reservation_date, :date
    field :reservation_time, :time
    field :party_size, :integer
    field :status, :string, default: "pending"
    field :special_requests, :string
    field :customer_name, :string
    field :customer_phone, :string
    field :customer_email, :string

    belongs_to :user, FoodReserve.Accounts.User
    belongs_to :restaurant, FoodReserve.Restaurants.Restaurant

    # Nueva relación con Order
    has_one :order, FoodReserve.Orders.Order

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(reservation, attrs) do
    reservation
    |> cast(attrs, [
      :reservation_date,
      :reservation_time,
      :party_size,
      :status,
      :special_requests,
      :customer_name,
      :customer_phone,
      :customer_email,
      :user_id,
      :restaurant_id
    ])
    |> validate_required([
      :reservation_date,
      :reservation_time,
      :party_size,
      :customer_name,
      :customer_phone,
      :user_id,
      :restaurant_id
    ])
    |> validate_inclusion(:status, @statuses)
    |> validate_number(:party_size, greater_than: 0, less_than_or_equal_to: 20)
    |> validate_format(:customer_email, ~r/^[^\s]+@[^\s]+\.[^\s]+$/,
      message: "debe ser un email válido"
    )
    |> validate_length(:customer_name, min: 2, max: 100)
    |> validate_length(:customer_phone, min: 10, max: 15)
    |> validate_future_date()
    |> validate_business_hours()
    |> validate_time_availability()
  end

  defp validate_future_date(changeset) do
    reservation_date = get_field(changeset, :reservation_date)

    if reservation_date && Date.compare(reservation_date, Date.utc_today()) == :lt do
      add_error(changeset, :reservation_date, "no puede ser en el pasado")
    else
      changeset
    end
  end

  defp validate_business_hours(changeset) do
    reservation_date = get_field(changeset, :reservation_date)
    reservation_time = get_field(changeset, :reservation_time)
    restaurant_id = get_field(changeset, :restaurant_id)

    if reservation_date && reservation_time && restaurant_id do
      validate_restaurant_hours(changeset, reservation_date, reservation_time, restaurant_id)
    else
      changeset
    end
  end

  defp validate_restaurant_hours(changeset, date, time, restaurant_id) do
    # Obtener horarios del restaurante
    working_hours = FoodReserve.Restaurants.get_public_working_hours(restaurant_id)
    day_of_week = get_day_of_week_string(date)

    case Enum.find(working_hours, fn wh -> wh.day_of_week == day_of_week end) do
      nil ->
        add_error(
          changeset,
          :reservation_date,
          "el restaurante no tiene horarios configurados para este día"
        )

      %{is_closed: true} ->
        add_error(changeset, :reservation_date, "el restaurante está cerrado este día")

      working_hour ->
        if working_hour.open_time && working_hour.close_time do
          # Verificar que la hora esté dentro del rango de operación
          # Permitir reservas hasta 1 hora antes del cierre
          latest_time = Time.add(working_hour.close_time, -60, :minute)

          cond do
            Time.compare(time, working_hour.open_time) == :lt ->
              add_error(
                changeset,
                :reservation_time,
                "debe ser después de las #{Calendar.strftime(working_hour.open_time, "%H:%M")}"
              )

            Time.compare(time, latest_time) == :gt ->
              add_error(
                changeset,
                :reservation_time,
                "debe ser antes de las #{Calendar.strftime(latest_time, "%H:%M")}"
              )

            true ->
              changeset
          end
        else
          add_error(
            changeset,
            :reservation_date,
            "el restaurante no tiene horarios válidos para este día"
          )
        end
    end
  end

  defp validate_time_availability(changeset) do
    reservation_date = get_field(changeset, :reservation_date)
    reservation_time = get_field(changeset, :reservation_time)
    restaurant_id = get_field(changeset, :restaurant_id)

    if reservation_date && reservation_time && restaurant_id do
      # Verificar si ya existe una reserva para este horario
      existing_reservations =
        FoodReserve.Reservations.get_existing_reservations(restaurant_id, reservation_date)

      if Enum.any?(existing_reservations, fn existing_time ->
           Time.compare(reservation_time, existing_time) == :eq
         end) do
        add_error(changeset, :reservation_time, "este horario ya no está disponible")
      else
        changeset
      end
    else
      changeset
    end
  end

  defp get_day_of_week_string(date) do
    case Date.day_of_week(date) do
      1 -> "monday"
      2 -> "tuesday"
      3 -> "wednesday"
      4 -> "thursday"
      5 -> "friday"
      6 -> "saturday"
      7 -> "sunday"
    end
  end

  def statuses, do: @statuses

  def status_name(status) do
    case status do
      "pending" -> "Pendiente"
      "confirmed" -> "Confirmada"
      "cancelled" -> "Cancelada"
      "completed" -> "Completada"
      _ -> status
    end
  end
end
