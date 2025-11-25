defmodule FoodReserve.Restaurants.Restaurant do
  use Ecto.Schema
  import Ecto.Changeset

  schema "restaurants" do
    field :name, :string
    field :description, :string
    field :address, :string
    field :phone_number, :string
    field :cuisine_type, :string
    belongs_to :user, FoodReserve.Accounts.User, foreign_key: :user_id

    has_many :reviews, FoodReserve.Reviews.Review

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(restaurant, attrs) do
    restaurant
    |> cast(attrs, [:name, :description, :address, :phone_number, :cuisine_type, :user_id])
    |> validate_required([:name, :description, :address, :phone_number, :cuisine_type, :user_id])
    |> foreign_key_constraint(:user_id)
  end
end
