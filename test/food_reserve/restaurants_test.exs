defmodule FoodReserve.RestaurantsTest do
  use FoodReserve.DataCase

  alias FoodReserve.Restaurants

  describe "restaurants" do
    alias FoodReserve.Restaurants.Restaurant

    import FoodReserve.AccountsFixtures, only: [user_scope_fixture: 0]
    import FoodReserve.RestaurantsFixtures

    @invalid_attrs %{
      "name" => nil,
      "address" => nil,
      "description" => nil,
      "phone_number" => nil,
      "cuisine_type" => nil
    }

    test "list_restaurants/1 returns all scoped restaurants" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      restaurant = restaurant_fixture(scope)
      other_restaurant = restaurant_fixture(other_scope)
      assert Restaurants.list_restaurants(scope) == [restaurant]
      assert Restaurants.list_restaurants(other_scope) == [other_restaurant]
    end

    test "get_restaurant!/2 returns the restaurant with given id" do
      scope = user_scope_fixture()
      restaurant = restaurant_fixture(scope)
      other_scope = user_scope_fixture()
      assert Restaurants.get_restaurant!(scope, restaurant.id) == restaurant

      assert_raise Ecto.NoResultsError, fn ->
        Restaurants.get_restaurant!(other_scope, restaurant.id)
      end
    end

    test "create_restaurant/2 with valid data creates a restaurant" do
      valid_attrs = %{
        "name" => "some name",
        "address" => "some address",
        "description" => "some description",
        "phone_number" => "some phone_number",
        "cuisine_type" => "some cuisine_type"
      }

      scope = user_scope_fixture()

      assert {:ok, %Restaurant{} = restaurant} = Restaurants.create_restaurant(scope, valid_attrs)
      assert restaurant.name == "some name"
      assert restaurant.address == "some address"
      assert restaurant.description == "some description"
      assert restaurant.phone_number == "some phone_number"
      assert restaurant.cuisine_type == "some cuisine_type"
      assert restaurant.user_id == scope.user.id
    end

    test "create_restaurant/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Restaurants.create_restaurant(scope, @invalid_attrs)
    end

    test "update_restaurant/3 with valid data updates the restaurant" do
      scope = user_scope_fixture()
      restaurant = restaurant_fixture(scope)

      update_attrs = %{
        "name" => "some updated name",
        "address" => "some updated address",
        "description" => "some updated description",
        "phone_number" => "some updated phone_number",
        "cuisine_type" => "some updated cuisine_type"
      }

      assert {:ok, %Restaurant{} = restaurant} =
               Restaurants.update_restaurant(scope, restaurant, update_attrs)

      assert restaurant.name == "some updated name"
      assert restaurant.address == "some updated address"
      assert restaurant.description == "some updated description"
      assert restaurant.phone_number == "some updated phone_number"
      assert restaurant.cuisine_type == "some updated cuisine_type"
    end

    test "update_restaurant/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      restaurant = restaurant_fixture(scope)

      assert_raise MatchError, fn ->
        Restaurants.update_restaurant(other_scope, restaurant, %{})
      end
    end

    test "update_restaurant/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      restaurant = restaurant_fixture(scope)

      assert {:error, %Ecto.Changeset{}} =
               Restaurants.update_restaurant(scope, restaurant, @invalid_attrs)

      assert restaurant == Restaurants.get_restaurant!(scope, restaurant.id)
    end

    test "delete_restaurant/2 deletes the restaurant" do
      scope = user_scope_fixture()
      restaurant = restaurant_fixture(scope)
      assert {:ok, %Restaurant{}} = Restaurants.delete_restaurant(scope, restaurant)

      assert_raise Ecto.NoResultsError, fn ->
        Restaurants.get_restaurant!(scope, restaurant.id)
      end
    end

    test "delete_restaurant/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      restaurant = restaurant_fixture(scope)
      assert_raise MatchError, fn -> Restaurants.delete_restaurant(other_scope, restaurant) end
    end

    test "change_restaurant/2 returns a restaurant changeset" do
      scope = user_scope_fixture()
      restaurant = restaurant_fixture(scope)
      assert %Ecto.Changeset{} = Restaurants.change_restaurant(scope, restaurant)
    end
  end

  describe "menu_items" do
    alias FoodReserve.Restaurants.MenuItem

    import FoodReserve.AccountsFixtures, only: [user_scope_fixture: 0]
    import FoodReserve.RestaurantsFixtures

    @invalid_attrs %{name: nil, description: nil, category: nil, available: nil, price: nil}

    test "list_menu_items/1 returns all scoped menu_items" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      menu_item = menu_item_fixture(scope)
      other_menu_item = menu_item_fixture(other_scope)
      assert Restaurants.list_menu_items(scope) == [menu_item]
      assert Restaurants.list_menu_items(other_scope) == [other_menu_item]
    end

    test "get_menu_item!/2 returns the menu_item with given id" do
      scope = user_scope_fixture()
      menu_item = menu_item_fixture(scope)
      other_scope = user_scope_fixture()
      assert Restaurants.get_menu_item!(scope, menu_item.id) == menu_item

      assert_raise Ecto.NoResultsError, fn ->
        Restaurants.get_menu_item!(other_scope, menu_item.id)
      end
    end

    test "create_menu_item/2 with valid data creates a menu_item" do
      valid_attrs = %{
        name: "some name",
        description: "some description",
        category: "some category",
        available: true,
        price: "120.5"
      }

      scope = user_scope_fixture()

      assert {:ok, %MenuItem{} = menu_item} = Restaurants.create_menu_item(scope, valid_attrs)
      assert menu_item.name == "some name"
      assert menu_item.description == "some description"
      assert menu_item.category == "some category"
      assert menu_item.available == true
      assert menu_item.price == Decimal.new("120.5")
      assert menu_item.user_id == scope.user.id
    end

    test "create_menu_item/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Restaurants.create_menu_item(scope, @invalid_attrs)
    end

    test "update_menu_item/3 with valid data updates the menu_item" do
      scope = user_scope_fixture()
      menu_item = menu_item_fixture(scope)

      update_attrs = %{
        name: "some updated name",
        description: "some updated description",
        category: "some updated category",
        available: false,
        price: "456.7"
      }

      assert {:ok, %MenuItem{} = menu_item} =
               Restaurants.update_menu_item(scope, menu_item, update_attrs)

      assert menu_item.name == "some updated name"
      assert menu_item.description == "some updated description"
      assert menu_item.category == "some updated category"
      assert menu_item.available == false
      assert menu_item.price == Decimal.new("456.7")
    end

    test "update_menu_item/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      menu_item = menu_item_fixture(scope)

      assert_raise MatchError, fn ->
        Restaurants.update_menu_item(other_scope, menu_item, %{})
      end
    end

    test "update_menu_item/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      menu_item = menu_item_fixture(scope)

      assert {:error, %Ecto.Changeset{}} =
               Restaurants.update_menu_item(scope, menu_item, @invalid_attrs)

      assert menu_item == Restaurants.get_menu_item!(scope, menu_item.id)
    end

    test "delete_menu_item/2 deletes the menu_item" do
      scope = user_scope_fixture()
      menu_item = menu_item_fixture(scope)
      assert {:ok, %MenuItem{}} = Restaurants.delete_menu_item(scope, menu_item)
      assert_raise Ecto.NoResultsError, fn -> Restaurants.get_menu_item!(scope, menu_item.id) end
    end

    test "delete_menu_item/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      menu_item = menu_item_fixture(scope)
      assert_raise MatchError, fn -> Restaurants.delete_menu_item(other_scope, menu_item) end
    end

    test "change_menu_item/2 returns a menu_item changeset" do
      scope = user_scope_fixture()
      menu_item = menu_item_fixture(scope)
      assert %Ecto.Changeset{} = Restaurants.change_menu_item(scope, menu_item)
    end
  end
end
