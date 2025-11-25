defmodule FoodReserve.Menus.MenuItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "menu_items" do
    field :name, :string
    field :description, :string
    field :price, :decimal
    field :category, :string
    field :available, :boolean, default: true
    belongs_to :menu, FoodReserve.Menus.Menu, foreign_key: :menu_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(menu_item, attrs) do
    menu_item
    |> cast(attrs, [:name, :description, :price, :category, :available, :menu_id])
    |> validate_required([:name, :description, :price, :menu_id])
    |> validate_number(:price, greater_than: 0)
    |> validate_length(:name, min: 2, max: 100)
    |> validate_length(:description, min: 5, max: 500)
    |> validate_length(:category, min: 2, max: 50)
    |> foreign_key_constraint(:menu_id)
  end
end
