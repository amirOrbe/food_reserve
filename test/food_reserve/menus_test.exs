defmodule FoodReserve.MenusTest do
  use FoodReserve.DataCase

  alias FoodReserve.Menus

  describe "menus" do
    alias FoodReserve.Menus.Menu

    import FoodReserve.AccountsFixtures, only: [user_scope_fixture: 0]
    import FoodReserve.MenusFixtures

    @invalid_attrs %{name: nil}

    test "list_menus/1 returns all scoped menus" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      menu = menu_fixture(scope)
      other_menu = menu_fixture(other_scope)
      assert Menus.list_menus(scope) == [menu]
      assert Menus.list_menus(other_scope) == [other_menu]
    end

    test "get_menu!/2 returns the menu with given id" do
      scope = user_scope_fixture()
      menu = menu_fixture(scope)
      other_scope = user_scope_fixture()
      assert Menus.get_menu!(scope, menu.id) == menu
      assert_raise Ecto.NoResultsError, fn -> Menus.get_menu!(other_scope, menu.id) end
    end

    test "create_menu/2 with valid data creates a menu" do
      valid_attrs = %{name: "some name"}
      scope = user_scope_fixture()

      assert {:ok, %Menu{} = menu} = Menus.create_menu(scope, valid_attrs)
      assert menu.name == "some name"
      assert menu.user_id == scope.user.id
    end

    test "create_menu/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Menus.create_menu(scope, @invalid_attrs)
    end

    test "update_menu/3 with valid data updates the menu" do
      scope = user_scope_fixture()
      menu = menu_fixture(scope)
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Menu{} = menu} = Menus.update_menu(scope, menu, update_attrs)
      assert menu.name == "some updated name"
    end

    test "update_menu/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      menu = menu_fixture(scope)

      assert_raise MatchError, fn ->
        Menus.update_menu(other_scope, menu, %{})
      end
    end

    test "update_menu/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      menu = menu_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Menus.update_menu(scope, menu, @invalid_attrs)
      assert menu == Menus.get_menu!(scope, menu.id)
    end

    test "delete_menu/2 deletes the menu" do
      scope = user_scope_fixture()
      menu = menu_fixture(scope)
      assert {:ok, %Menu{}} = Menus.delete_menu(scope, menu)
      assert_raise Ecto.NoResultsError, fn -> Menus.get_menu!(scope, menu.id) end
    end

    test "delete_menu/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      menu = menu_fixture(scope)
      assert_raise MatchError, fn -> Menus.delete_menu(other_scope, menu) end
    end

    test "change_menu/2 returns a menu changeset" do
      scope = user_scope_fixture()
      menu = menu_fixture(scope)
      assert %Ecto.Changeset{} = Menus.change_menu(scope, menu)
    end
  end

  describe "menu_items" do
    alias FoodReserve.Menus.MenuItem

    import FoodReserve.AccountsFixtures, only: [user_scope_fixture: 0]
    import FoodReserve.MenusFixtures

    @invalid_attrs %{name: nil, description: nil, price: nil}

    test "list_menu_items/1 returns all scoped menu_items" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      menu_item = menu_item_fixture(scope)
      other_menu_item = menu_item_fixture(other_scope)
      assert Menus.list_menu_items(scope) == [menu_item]
      assert Menus.list_menu_items(other_scope) == [other_menu_item]
    end

    test "get_menu_item!/2 returns the menu_item with given id" do
      scope = user_scope_fixture()
      menu_item = menu_item_fixture(scope)
      other_scope = user_scope_fixture()
      assert Menus.get_menu_item!(scope, menu_item.id) == menu_item
      assert_raise Ecto.NoResultsError, fn -> Menus.get_menu_item!(other_scope, menu_item.id) end
    end

    test "create_menu_item/2 with valid data creates a menu_item" do
      valid_attrs = %{name: "some name", description: "some description", price: "120.5"}
      scope = user_scope_fixture()

      assert {:ok, %MenuItem{} = menu_item} = Menus.create_menu_item(scope, valid_attrs)
      assert menu_item.name == "some name"
      assert menu_item.description == "some description"
      assert menu_item.price == Decimal.new("120.5")
      assert menu_item.user_id == scope.user.id
    end

    test "create_menu_item/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Menus.create_menu_item(scope, @invalid_attrs)
    end

    test "update_menu_item/3 with valid data updates the menu_item" do
      scope = user_scope_fixture()
      menu_item = menu_item_fixture(scope)
      update_attrs = %{name: "some updated name", description: "some updated description", price: "456.7"}

      assert {:ok, %MenuItem{} = menu_item} = Menus.update_menu_item(scope, menu_item, update_attrs)
      assert menu_item.name == "some updated name"
      assert menu_item.description == "some updated description"
      assert menu_item.price == Decimal.new("456.7")
    end

    test "update_menu_item/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      menu_item = menu_item_fixture(scope)

      assert_raise MatchError, fn ->
        Menus.update_menu_item(other_scope, menu_item, %{})
      end
    end

    test "update_menu_item/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      menu_item = menu_item_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Menus.update_menu_item(scope, menu_item, @invalid_attrs)
      assert menu_item == Menus.get_menu_item!(scope, menu_item.id)
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
      assert_raise MatchError, fn -> Menus.delete_menu_item(other_scope, menu_item) end
    end

    test "change_menu_item/2 returns a menu_item changeset" do
      scope = user_scope_fixture()
      menu_item = menu_item_fixture(scope)
      assert %Ecto.Changeset{} = Menus.change_menu_item(scope, menu_item)
    end
  end
end
