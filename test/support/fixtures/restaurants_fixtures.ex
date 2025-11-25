defmodule FoodReserve.RestaurantsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `FoodReserve.Restaurants` context.
  """

  import FoodReserve.AccountsFixtures

  @doc """
  Generate a restaurant.
  """
  def restaurant_fixture(scope_or_attrs \\ %{})

  def restaurant_fixture(%FoodReserve.Accounts.Scope{} = scope) do
    attrs = %{
      "address" => "123 Main St",
      "cuisine_type" => "Italian",
      "description" => "A lovely place.",
      "name" => "The Grand Restaurant",
      "phone_number" => "555-1234",
      "user_id" => scope.user.id
    }

    {:ok, restaurant} = FoodReserve.Restaurants.create_restaurant(scope, attrs)
    restaurant
  end

  def restaurant_fixture(attrs) when is_map(attrs) do
    # Create a restaurant owner user if not provided
    user = Map.get(attrs, :user) || user_fixture(%{role: "restaurant_owner"})

    # Remove :user from attrs and ensure we only have string keys for the changeset
    attrs =
      attrs
      |> Map.delete(:user)
      |> Enum.into(%{
        "address" => "123 Main St",
        "cuisine_type" => "Italian",
        "description" => "A lovely place.",
        "name" => "The Grand Restaurant",
        "phone_number" => "555-1234",
        "user_id" => user.id
      })

    scope = %FoodReserve.Accounts.Scope{user: user}
    {:ok, restaurant} = FoodReserve.Restaurants.create_restaurant(scope, attrs)

    restaurant
  end

  @doc """
  Generate a menu_item.
  """
  def menu_item_fixture(scope, attrs \\ %{}) do
    # Crear un menú primero si no se proporciona menu_id
    menu =
      case attrs[:menu_id] || attrs["menu_id"] do
        nil ->
          restaurant = restaurant_fixture(scope)

          {:ok, menu} =
            FoodReserve.Menus.create_menu(scope, %{
              name: "Test Menu",
              restaurant_id: restaurant.id
            })

          menu

        menu_id ->
          FoodReserve.Menus.get_menu!(scope, menu_id)
      end

    attrs =
      Enum.into(attrs, %{
        available: true,
        category: "some category",
        description: "some description",
        name: "some name",
        price: "120.5",
        menu_id: menu.id
      })

    {:ok, menu_item} = FoodReserve.Menus.create_menu_item(scope, attrs)
    menu_item
  end

  @doc """
  Generate a working_hour.
  """
  def working_hour_fixture(scope, attrs \\ %{}) do
    restaurant = restaurant_fixture(scope)

    attrs =
      Enum.into(attrs, %{
        "close_time" => ~T[22:00:00],
        "day_of_week" => "monday",
        "is_closed" => false,
        "open_time" => ~T[09:00:00]
      })

    {:ok, working_hour} = FoodReserve.Restaurants.upsert_working_hour(scope, restaurant.id, attrs)

    working_hour
  end
end
