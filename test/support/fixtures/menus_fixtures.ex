defmodule FoodReserve.MenusFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `FoodReserve.Menus` context.
  """

  import FoodReserve.RestaurantsFixtures

  @doc """
  Generate a menu.
  """
  def menu_fixture(scope_or_attrs \\ %{})

  def menu_fixture(%FoodReserve.Accounts.Scope{} = scope) do
    # Create a restaurant for this user if they don't have one
    restaurant = restaurant_fixture(%{user: scope.user})

    attrs = %{
      "name" => "Main Menu",
      "restaurant_id" => restaurant.id
    }

    {:ok, menu} = FoodReserve.Menus.create_menu(scope, attrs)
    FoodReserve.Repo.preload(menu, :restaurant)
  end

  def menu_fixture(attrs) when is_map(attrs) do
    restaurant = Map.get(attrs, :restaurant) || restaurant_fixture()

    # Ensure the user is loaded
    restaurant = FoodReserve.Repo.preload(restaurant, :user)

    attrs =
      attrs
      |> Map.delete(:restaurant)
      |> Enum.into(%{
        "name" => "Main Menu",
        "restaurant_id" => restaurant.id
      })

    # Create a scope for the restaurant owner
    scope = FoodReserve.Accounts.Scope.for_user(restaurant.user)
    {:ok, menu} = FoodReserve.Menus.create_menu(scope, attrs)

    FoodReserve.Repo.preload(menu, :restaurant)
  end

  @doc """
  Generate a menu_item.
  """
  def menu_item_fixture(scope_or_attrs \\ %{})

  def menu_item_fixture(%FoodReserve.Accounts.Scope{} = scope) do
    # Create a menu for this user if they don't have one
    menu = menu_fixture(scope)

    attrs = %{
      "description" => "Delicious and fresh.",
      "name" => "Sample Dish",
      "price" => "120.5",
      "menu_id" => menu.id
    }

    {:ok, menu_item} = FoodReserve.Menus.create_menu_item(scope, attrs)
    FoodReserve.Repo.preload(menu_item, menu: :restaurant)
  end

  def menu_item_fixture(attrs) when is_map(attrs) do
    menu = Map.get(attrs, :menu) || menu_fixture()

    attrs =
      attrs
      |> Map.delete(:menu)
      |> Enum.into(%{
        "description" => "Delicious and fresh.",
        "name" => "Sample Dish",
        "price" => "120.5",
        "menu_id" => menu.id
      })

    # Create a scope for the restaurant owner
    restaurant = FoodReserve.Repo.preload(menu.restaurant, :user)
    scope = FoodReserve.Accounts.Scope.for_user(restaurant.user)
    {:ok, menu_item} = FoodReserve.Menus.create_menu_item(scope, attrs)
    FoodReserve.Repo.preload(menu_item, menu: :restaurant)
  end
end
