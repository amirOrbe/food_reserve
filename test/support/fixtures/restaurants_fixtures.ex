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
end
