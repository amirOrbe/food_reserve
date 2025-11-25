defmodule FoodReserve.Reviews.Review do
  use Ecto.Schema
  import Ecto.Changeset

  alias FoodReserve.Accounts.User
  alias FoodReserve.Restaurants.Restaurant
  alias FoodReserve.Reservations.Reservation

  @ratings [1, 2, 3, 4, 5]

  schema "reviews" do
    field :food_rating, :integer
    field :service_rating, :integer
    field :comment, :string

    belongs_to :user, User
    belongs_to :restaurant, Restaurant
    belongs_to :reservation, Reservation

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(review, attrs) do
    review
    |> cast(attrs, [
      :food_rating,
      :service_rating,
      :comment,
      :user_id,
      :restaurant_id,
      :reservation_id
    ])
    |> validate_required([:food_rating, :service_rating, :user_id, :restaurant_id])
    |> validate_inclusion(:food_rating, @ratings, message: "debe ser entre 1 y 5")
    |> validate_inclusion(:service_rating, @ratings, message: "debe ser entre 1 y 5")
    |> validate_length(:comment, max: 1000, message: "no puede exceder 1000 caracteres")
    |> unique_constraint([:user_id, :restaurant_id],
      name: :reviews_user_restaurant_unique,
      message: "ya has calificado este restaurante"
    )
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:restaurant_id)
    |> foreign_key_constraint(:reservation_id)
  end

  @doc """
  Calcula el promedio general de una reseña (comida + servicio / 2).
  """
  def average_rating(%__MODULE__{food_rating: food, service_rating: service}) do
    (food + service) / 2
  end

  @doc """
  Retorna las opciones de calificación disponibles.
  """
  def rating_options, do: @ratings
end
