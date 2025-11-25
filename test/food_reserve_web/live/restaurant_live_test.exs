defmodule FoodReserveWeb.RestaurantLiveTest do
  use FoodReserveWeb.ConnCase

  import Phoenix.LiveViewTest
  import FoodReserve.RestaurantsFixtures

  @create_attrs %{
    name: "some name",
    address: "some address",
    description: "some description",
    phone_number: "some phone_number",
    cuisine_type: "some cuisine_type"
  }
  @update_attrs %{
    name: "some updated name",
    address: "some updated address",
    description: "some updated description",
    phone_number: "some updated phone_number",
    cuisine_type: "some updated cuisine_type"
  }
  @invalid_attrs %{
    name: nil,
    address: nil,
    description: nil,
    phone_number: nil,
    cuisine_type: nil
  }

  setup :register_and_log_in_restaurant_owner

  defp create_restaurant(%{scope: scope}) do
    restaurant = restaurant_fixture(%{user: scope.user})

    %{restaurant: restaurant}
  end

  describe "Index" do
    setup [:create_restaurant]

    test "lists all restaurants", %{conn: conn, restaurant: restaurant} do
      {:ok, _index_live, html} = live(conn, ~p"/restaurants")

      # El título puede estar en español o inglés
      assert html =~ "Listing Restaurants" || html =~ "Lista de Restaurantes" ||
               html =~ "Mis Restaurantes"

      assert html =~ restaurant.name
    end

    test "saves new restaurant", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/restaurants")

      assert {:ok, form_live, _} =
               index_live
               |> element("a.btn-primary")
               |> render_click()
               |> follow_redirect(conn, ~p"/restaurants/new")

      assert render(form_live) =~ "New Restaurant" || render(form_live) =~ "Nuevo Restaurante"

      assert form_live
             |> form("#restaurant-form", restaurant: @invalid_attrs)
             |> render_change() =~ "t be blank" ||
               form_live
               |> form("#restaurant-form", restaurant: @invalid_attrs)
               |> render_change() =~ "no puede estar"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#restaurant-form", restaurant: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/restaurants")

      html = render(index_live)

      assert html =~ "Restaurant created successfully" ||
               html =~ "Restaurante creado" ||
               html =~ "creado con éxito"

      assert html =~ "some name"
    end

    test "updates restaurant in listing", %{conn: conn, restaurant: restaurant} do
      {:ok, index_live, _html} = live(conn, ~p"/restaurants")

      assert {:ok, form_live, _html} =
               index_live
               |> element("a[href=\"/restaurants/#{restaurant.id}/edit\"]")
               |> render_click()
               |> follow_redirect(conn, ~p"/restaurants/#{restaurant}/edit")

      assert render(form_live) =~ "Edit Restaurant" || render(form_live) =~ "Editar Restaurante"

      change_result =
        form_live
        |> form("#restaurant-form", restaurant: @invalid_attrs)
        |> render_change()

      assert change_result =~ "t be blank" || change_result =~ "no puede estar"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#restaurant-form", restaurant: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/restaurants")

      html = render(index_live)

      assert html =~ "Restaurant updated successfully" ||
               html =~ "Restaurante actualizado" ||
               html =~ "actualizado con éxito"

      assert html =~ "some updated name"
    end

    test "deletes restaurant in listing", %{conn: conn, restaurant: restaurant} do
      {:ok, index_live, _html} = live(conn, ~p"/restaurants")

      delete_btn =
        index_live
        |> element("a[data-confirm]")

      assert delete_btn |> render_click()
      refute has_element?(index_live, "#restaurants-#{restaurant.id}")
    end
  end

  describe "Show" do
    setup [:create_restaurant]

    test "displays restaurant", %{conn: conn, restaurant: restaurant} do
      {:ok, _show_live, html} = live(conn, ~p"/restaurants/#{restaurant}")

      assert html =~ "Show Restaurant" || html =~ "Ver Restaurante"
      assert html =~ restaurant.name
    end

    test "updates restaurant and returns to show", %{conn: conn, restaurant: restaurant} do
      {:ok, show_live, _html} = live(conn, ~p"/restaurants/#{restaurant}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a[href=\"/restaurants/#{restaurant.id}/edit?return_to=show\"]")
               |> render_click()
               |> follow_redirect(conn, ~p"/restaurants/#{restaurant}/edit?return_to=show")

      assert render(form_live) =~ "Edit Restaurant" || render(form_live) =~ "Editar Restaurante"

      change_result =
        form_live
        |> form("#restaurant-form", restaurant: @invalid_attrs)
        |> render_change()

      assert change_result =~ "t be blank" || change_result =~ "no puede estar"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#restaurant-form", restaurant: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/restaurants/#{restaurant}")

      html = render(show_live)

      assert html =~ "Restaurant updated successfully" ||
               html =~ "Restaurante actualizado" ||
               html =~ "actualizado con éxito"

      assert html =~ "some updated name"
    end
  end
end
