defmodule FoodReserve.RestaurantsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `FoodReserve.Restaurants` context.
  """

  import FoodReserve.AccountsFixtures

  @doc """
  Generate a restaurant.
  """
  def restaurant_fixture(attrs \\ %{}) do
    user = attrs[:user] || user_fixture()

    attrs =
      Enum.into(attrs, %{
        address: "123 Main St",
        cuisine_type: "Italian",
        description: "A lovely place.",
        name: "The Grand Restaurant",
        phone_number: "555-1234",
        user_id: user.id
      })

    scope = %FoodReserve.Accounts.Scope{user: user}
    {:ok, restaurant} = FoodReserve.Restaurants.create_restaurant(scope, attrs)

    restaurant
  end

end
