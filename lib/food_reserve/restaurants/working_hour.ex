defmodule FoodReserve.Restaurants.WorkingHour do
  use Ecto.Schema
  import Ecto.Changeset

  @days_of_week [
    "monday",
    "tuesday",
    "wednesday",
    "thursday",
    "friday",
    "saturday",
    "sunday"
  ]

  schema "working_hours" do
    field :day_of_week, :string
    field :open_time, :time
    field :close_time, :time
    field :is_closed, :boolean, default: false
    belongs_to :restaurant, FoodReserve.Restaurants.Restaurant

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(working_hour, attrs) do
    working_hour
    |> cast(attrs, [:day_of_week, :open_time, :close_time, :is_closed, :restaurant_id])
    |> validate_required([:day_of_week, :restaurant_id])
    |> validate_inclusion(:day_of_week, @days_of_week)
    |> validate_times()
    |> unique_constraint([:restaurant_id, :day_of_week],
      message: "Ya existe un horario para este día"
    )
  end

  defp validate_times(changeset) do
    is_closed = get_field(changeset, :is_closed)

    if is_closed do
      changeset
    else
      changeset
      |> validate_required([:open_time, :close_time])
      |> validate_time_order()
    end
  end

  defp validate_time_order(changeset) do
    open_time = get_field(changeset, :open_time)
    close_time = get_field(changeset, :close_time)

    if open_time && close_time && Time.compare(open_time, close_time) != :lt do
      add_error(changeset, :close_time, "debe ser posterior a la hora de apertura")
    else
      changeset
    end
  end

  def days_of_week, do: @days_of_week

  def day_name(day) do
    case day do
      "monday" -> "Lunes"
      "tuesday" -> "Martes"
      "wednesday" -> "Miércoles"
      "thursday" -> "Jueves"
      "friday" -> "Viernes"
      "saturday" -> "Sábado"
      "sunday" -> "Domingo"
      _ -> day
    end
  end
end
