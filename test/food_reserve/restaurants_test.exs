defmodule FoodReserve.RestaurantsTest do
  use FoodReserve.DataCase

  alias FoodReserve.Restaurants
  alias FoodReserve.Menus

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
    alias FoodReserve.Menus.MenuItem

    import FoodReserve.AccountsFixtures, only: [user_scope_fixture: 0]
    import FoodReserve.RestaurantsFixtures

    @invalid_attrs %{name: nil, description: nil, category: nil, available: nil, price: nil}

    test "list_menu_items/1 returns all scoped menu_items" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      menu_item = menu_item_fixture(scope)
      other_menu_item = menu_item_fixture(other_scope)
      # Comparar solo por IDs ya que el preload puede ser diferente
      result_items = Menus.list_menu_items(scope)
      assert length(result_items) == 1
      assert hd(result_items).id == menu_item.id

      other_result_items = Menus.list_menu_items(other_scope)
      assert length(other_result_items) == 1
      assert hd(other_result_items).id == other_menu_item.id
    end

    test "get_menu_item!/2 returns the menu_item with given id" do
      scope = user_scope_fixture()
      menu_item = menu_item_fixture(scope)
      other_scope = user_scope_fixture()
      # Comparar solo campos relevantes, no la asociación preloaded
      fetched_item = Menus.get_menu_item!(scope, menu_item.id)
      assert fetched_item.id == menu_item.id
      assert fetched_item.name == menu_item.name
      assert fetched_item.price == menu_item.price

      assert_raise Ecto.NoResultsError, fn ->
        Menus.get_menu_item!(other_scope, menu_item.id)
      end
    end

    test "create_menu_item/2 with valid data creates a menu_item" do
      scope = user_scope_fixture()
      restaurant = restaurant_fixture(scope)
      {:ok, menu} = Menus.create_menu(scope, %{name: "Test Menu", restaurant_id: restaurant.id})

      valid_attrs = %{
        name: "some name",
        description: "some description",
        category: "some category",
        available: true,
        price: "120.5",
        menu_id: menu.id
      }

      assert {:ok, %MenuItem{} = menu_item} = Menus.create_menu_item(scope, valid_attrs)
      assert menu_item.name == "some name"
      assert menu_item.description == "some description"
      assert menu_item.category == "some category"
      assert menu_item.available == true
      assert menu_item.price == Decimal.new("120.5")
    end

    test "create_menu_item/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Menus.create_menu_item(scope, @invalid_attrs)
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
               Menus.update_menu_item(scope, menu_item, update_attrs)

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

      assert_raise Ecto.NoResultsError, fn ->
        Menus.update_menu_item(other_scope, menu_item, %{})
      end
    end

    test "update_menu_item/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      menu_item = menu_item_fixture(scope)

      assert {:error, %Ecto.Changeset{}} =
               Menus.update_menu_item(scope, menu_item, @invalid_attrs)

      updated_item = Menus.get_menu_item!(scope, menu_item.id)
      assert menu_item.id == updated_item.id
      assert menu_item.name == updated_item.name
      assert menu_item.description == updated_item.description
      assert menu_item.price == updated_item.price
    end

    test "delete_menu_item/2 deletes the menu_item" do
      scope = user_scope_fixture()
      menu_item = menu_item_fixture(scope)
      assert {:ok, %MenuItem{}} = Menus.delete_menu_item(scope, menu_item)
      assert_raise Ecto.NoResultsError, fn -> Menus.get_menu_item!(scope, menu_item.id) end
    end

    test "delete_menu_item/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      menu_item = menu_item_fixture(scope)

      assert_raise Ecto.NoResultsError, fn ->
        Menus.delete_menu_item(other_scope, menu_item)
      end
    end

    test "change_menu_item/2 returns a menu_item changeset" do
      scope = user_scope_fixture()
      menu_item = menu_item_fixture(scope)
      # La función tiene la firma change_menu_item(menu_item, attrs)
      assert %Ecto.Changeset{} = Menus.change_menu_item(menu_item, %{})
    end
  end

  describe "working_hours" do
    alias FoodReserve.Restaurants.WorkingHour

    import FoodReserve.AccountsFixtures, only: [user_scope_fixture: 0]
    import FoodReserve.RestaurantsFixtures

    @invalid_attrs %{day_of_week: nil, open_time: nil, close_time: nil, is_closed: nil}

    test "list_working_hours/1 returns all scoped working_hours" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      working_hour = working_hour_fixture(scope)
      other_working_hour = working_hour_fixture(other_scope)
      assert Restaurants.list_working_hours(scope) == [working_hour]
      assert Restaurants.list_working_hours(other_scope) == [other_working_hour]
    end

    test "get_working_hour!/2 returns the working_hour with given id" do
      scope = user_scope_fixture()
      working_hour = working_hour_fixture(scope)
      other_scope = user_scope_fixture()
      assert Restaurants.get_working_hour!(scope, working_hour.id) == working_hour

      assert_raise Ecto.NoResultsError, fn ->
        Restaurants.get_working_hour!(other_scope, working_hour.id)
      end
    end

    test "upsert_working_hour/3 with valid data creates a working_hour" do
      valid_attrs = %{
        "day_of_week" => "monday",
        "open_time" => ~T[14:00:00],
        "close_time" => ~T[18:00:00],
        "is_closed" => true
      }

      scope = user_scope_fixture()
      restaurant = restaurant_fixture(scope)

      assert {:ok, %WorkingHour{} = working_hour} =
               Restaurants.upsert_working_hour(scope, restaurant.id, valid_attrs)

      assert working_hour.day_of_week == "monday"
      assert working_hour.open_time == ~T[14:00:00]
      assert working_hour.close_time == ~T[18:00:00]
      assert working_hour.is_closed == true
      assert working_hour.restaurant_id == restaurant.id
    end

    test "upsert_working_hour/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      restaurant = restaurant_fixture(scope)
      assert {:error, %Ecto.Changeset{}} =
               Restaurants.upsert_working_hour(scope, restaurant.id, %{
                 "day_of_week" => "invalid_day",
                 "open_time" => nil,
                 "close_time" => nil,
                 "is_closed" => nil
               })
    end

    test "upsert_working_hour/3 with valid data updates the working_hour" do
      scope = user_scope_fixture()
      working_hour = working_hour_fixture(scope)

      update_attrs = %{
        "day_of_week" => "tuesday",
        "open_time" => ~T[15:01:01],
        "close_time" => ~T[22:01:01],
        "is_closed" => false,
        "id" => working_hour.id
      }

      assert {:ok, %WorkingHour{} = updated_working_hour} =
               Restaurants.upsert_working_hour(scope, working_hour.restaurant_id, update_attrs)

      assert updated_working_hour.day_of_week == "tuesday"
      assert updated_working_hour.open_time == ~T[15:01:01]
      assert updated_working_hour.close_time == ~T[22:01:01]
      assert updated_working_hour.is_closed == false
    end

    test "upsert_working_hour/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      working_hour = working_hour_fixture(scope)

      assert_raise Ecto.NoResultsError, fn ->
        Restaurants.upsert_working_hour(other_scope, working_hour.restaurant_id, %{
          id: working_hour.id,
          day_of_week: "monday"
        })
      end
    end

    test "delete_working_hour/2 deletes the working_hour" do
      scope = user_scope_fixture()
      working_hour = working_hour_fixture(scope)
      assert {:ok, %WorkingHour{}} = Restaurants.delete_working_hour(scope, working_hour)

      assert_raise Ecto.NoResultsError, fn ->
        Restaurants.get_working_hour!(scope, working_hour.id)
      end
    end

    test "delete_working_hour/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      working_hour = working_hour_fixture(scope)

      assert_raise Ecto.NoResultsError, fn ->
        Restaurants.delete_working_hour(other_scope, working_hour)
      end
    end

    test "change_working_hour/2 returns a working_hour changeset" do
      scope = user_scope_fixture()
      working_hour = working_hour_fixture(scope)
      assert %Ecto.Changeset{} = Restaurants.change_working_hour(scope, working_hour)
    end
  end
end
