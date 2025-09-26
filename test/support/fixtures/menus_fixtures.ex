defmodule FoodReserve.MenusFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `FoodReserve.Menus` context.
  """

  import FoodReserve.RestaurantsFixtures

  @doc """
  Generate a menu.
  """
  def menu_fixture(attrs \\ %{}) do
    restaurant = attrs[:restaurant] || restaurant_fixture()

    attrs =
      Enum.into(attrs, %{
        name: "Main Menu",
        restaurant_id: restaurant.id
      })

    {:ok, menu} = FoodReserve.Menus.create_menu(attrs)

    menu
  end

  @doc """
  Generate a menu_item.
  """
  def menu_item_fixture(attrs \\ %{}) do
    menu = attrs[:menu] || menu_fixture()

    attrs =
      Enum.into(attrs, %{
        description: "Delicious and fresh.",
        name: "Sample Dish",
        price: "120.5",
        menu_id: menu.id
      })

    {:ok, menu_item} = FoodReserve.Menus.create_menu_item(attrs)
    menu_item
  end
end
