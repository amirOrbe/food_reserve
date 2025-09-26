defmodule FoodReserve.Menus.Menu do
  use Ecto.Schema
  import Ecto.Changeset

  schema "menus" do
    field :name, :string
    belongs_to :restaurant, FoodReserve.Restaurants.Restaurant, foreign_key: :restaurant_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(menu, attrs) do
    menu
    |> cast(attrs, [:name, :restaurant_id])
    |> validate_required([:name, :restaurant_id])
    |> foreign_key_constraint(:restaurant_id)
  end
end
