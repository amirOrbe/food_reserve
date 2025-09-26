defmodule FoodReserveWeb.RestaurantLiveTest do
  use FoodReserveWeb.ConnCase

  import Phoenix.LiveViewTest
  import FoodReserve.RestaurantsFixtures

  @create_attrs %{name: "some name", address: "some address", description: "some description", phone_number: "some phone_number", cuisine_type: "some cuisine_type"}
  @update_attrs %{name: "some updated name", address: "some updated address", description: "some updated description", phone_number: "some updated phone_number", cuisine_type: "some updated cuisine_type"}
  @invalid_attrs %{name: nil, address: nil, description: nil, phone_number: nil, cuisine_type: nil}

  setup :register_and_log_in_user

  defp create_restaurant(%{scope: scope}) do
    restaurant = restaurant_fixture(scope)

    %{restaurant: restaurant}
  end

  describe "Index" do
    setup [:create_restaurant]

    test "lists all restaurants", %{conn: conn, restaurant: restaurant} do
      {:ok, _index_live, html} = live(conn, ~p"/restaurants")

      assert html =~ "Listing Restaurants"
      assert html =~ restaurant.name
    end

    test "saves new restaurant", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/restaurants")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Restaurant")
               |> render_click()
               |> follow_redirect(conn, ~p"/restaurants/new")

      assert render(form_live) =~ "New Restaurant"

      assert form_live
             |> form("#restaurant-form", restaurant: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#restaurant-form", restaurant: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/restaurants")

      html = render(index_live)
      assert html =~ "Restaurant created successfully"
      assert html =~ "some name"
    end

    test "updates restaurant in listing", %{conn: conn, restaurant: restaurant} do
      {:ok, index_live, _html} = live(conn, ~p"/restaurants")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#restaurants-#{restaurant.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/restaurants/#{restaurant}/edit")

      assert render(form_live) =~ "Edit Restaurant"

      assert form_live
             |> form("#restaurant-form", restaurant: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#restaurant-form", restaurant: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/restaurants")

      html = render(index_live)
      assert html =~ "Restaurant updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes restaurant in listing", %{conn: conn, restaurant: restaurant} do
      {:ok, index_live, _html} = live(conn, ~p"/restaurants")

      assert index_live |> element("#restaurants-#{restaurant.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#restaurants-#{restaurant.id}")
    end
  end

  describe "Show" do
    setup [:create_restaurant]

    test "displays restaurant", %{conn: conn, restaurant: restaurant} do
      {:ok, _show_live, html} = live(conn, ~p"/restaurants/#{restaurant}")

      assert html =~ "Show Restaurant"
      assert html =~ restaurant.name
    end

    test "updates restaurant and returns to show", %{conn: conn, restaurant: restaurant} do
      {:ok, show_live, _html} = live(conn, ~p"/restaurants/#{restaurant}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/restaurants/#{restaurant}/edit?return_to=show")

      assert render(form_live) =~ "Edit Restaurant"

      assert form_live
             |> form("#restaurant-form", restaurant: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#restaurant-form", restaurant: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/restaurants/#{restaurant}")

      html = render(show_live)
      assert html =~ "Restaurant updated successfully"
      assert html =~ "some updated name"
    end
  end
end
