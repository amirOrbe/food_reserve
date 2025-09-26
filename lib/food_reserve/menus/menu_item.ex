defmodule FoodReserve.Menus.MenuItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "menu_items" do
    field :name, :string
    field :description, :string
    field :price, :decimal
    belongs_to :menu, FoodReserve.Menus.Menu, foreign_key: :menu_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(menu_item, attrs) do
    menu_item
    |> cast(attrs, [:name, :description, :price, :menu_id])
    |> validate_required([:name, :description, :price, :menu_id])
    |> foreign_key_constraint(:menu_id)
  end
end
