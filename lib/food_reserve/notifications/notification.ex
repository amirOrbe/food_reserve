defmodule FoodReserve.Notifications.Notification do
  use Ecto.Schema
  import Ecto.Changeset

  alias FoodReserve.Accounts.User
  alias FoodReserve.Restaurants.Restaurant
  alias FoodReserve.Reservations.Reservation

  @notification_types [
    "reservation_created",
    "reservation_confirmed",
    "reservation_declined",
    "review_reminder",
    "general"
  ]

  schema "notifications" do
    field :title, :string
    field :message, :string
    field :type, :string
    field :read, :boolean, default: false

    belongs_to :user, User
    belongs_to :restaurant, Restaurant
    belongs_to :reservation, Reservation

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [:title, :message, :type, :read, :user_id, :restaurant_id, :reservation_id])
    |> validate_required([:title, :message, :type, :user_id])
    |> validate_inclusion(:type, @notification_types, message: "debe ser un tipo válido")
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:restaurant_id)
    |> foreign_key_constraint(:reservation_id)
  end

  @doc """
  Retorna los tipos de notificación disponibles.
  """
  def notification_types, do: @notification_types

  @doc """
  Retorna el icono apropiado para cada tipo de notificación.
  """
  def get_icon_for_type(type) do
    case type do
      "reservation_created" -> "hero-calendar-days"
      "reservation_confirmed" -> "hero-check-circle"
      "reservation_declined" -> "hero-x-circle"
      "review_reminder" -> "hero-star"
      "general" -> "hero-bell"
      _ -> "hero-bell"
    end
  end

  @doc """
  Retorna el color apropiado para cada tipo de notificación.
  """
  def get_color_for_type(type) do
    case type do
      "reservation_created" -> "blue"
      "reservation_confirmed" -> "green"
      "reservation_declined" -> "red"
      "review_reminder" -> "yellow"
      "general" -> "gray"
      _ -> "gray"
    end
  end
end
