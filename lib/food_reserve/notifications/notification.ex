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
    field :action_text, :string
    field :action_url, :string

    belongs_to :user, User
    belongs_to :restaurant, Restaurant
    belongs_to :reservation, Reservation

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [
      :title,
      :message,
      :type,
      :read,
      :user_id,
      :restaurant_id,
      :reservation_id,
      :action_text,
      :action_url
    ])
    |> validate_required([:title, :message, :type, :user_id])
    |> validate_inclusion(:type, @notification_types, message: "must be a valid type")
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:restaurant_id)
    |> foreign_key_constraint(:reservation_id)
  end

  @doc """
  Returns available notification types.
  """
  def notification_types, do: @notification_types

  @doc """
  Returns the appropriate icon for each notification type.
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
  Returns the appropriate color for each notification type.
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
