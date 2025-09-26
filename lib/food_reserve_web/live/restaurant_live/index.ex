defmodule FoodReserveWeb.RestaurantLive.Index do
  use FoodReserveWeb, :live_view

  alias FoodReserve.Restaurants

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Restaurants
        <:actions>
          <.button variant="primary" navigate={~p"/restaurants/new"}>
            <.icon name="hero-plus" /> New Restaurant
          </.button>
        </:actions>
      </.header>

      <.table
        id="restaurants"
        rows={@streams.restaurants}
        row_click={fn {_id, restaurant} -> JS.navigate(~p"/restaurants/#{restaurant}") end}
      >
        <:col :let={{_id, restaurant}} label="Name">{restaurant.name}</:col>
        <:col :let={{_id, restaurant}} label="Description">{restaurant.description}</:col>
        <:col :let={{_id, restaurant}} label="Address">{restaurant.address}</:col>
        <:col :let={{_id, restaurant}} label="Phone number">{restaurant.phone_number}</:col>
        <:col :let={{_id, restaurant}} label="Cuisine type">{restaurant.cuisine_type}</:col>
        <:action :let={{_id, restaurant}}>
          <div class="sr-only">
            <.link navigate={~p"/restaurants/#{restaurant}"}>Show</.link>
          </div>
          <.link navigate={~p"/restaurants/#{restaurant}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, restaurant}}>
          <.link
            phx-click={JS.push("delete", value: %{id: restaurant.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    scope = socket.assigns.current_scope

    if connected?(socket) do
      Restaurants.subscribe_restaurants(scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Restaurants")
     |> stream(:restaurants, Restaurants.list_restaurants(scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    scope = socket.assigns.current_scope
    restaurant = Restaurants.get_restaurant!(scope, id)
    {:ok, _} = Restaurants.delete_restaurant(scope, restaurant)

    {:noreply, stream_delete(socket, :restaurants, restaurant)}
  end

  @impl true
  def handle_info({:created, restaurant}, socket) do
    {:noreply, stream_insert(socket, :restaurants, restaurant)}
  end

  def handle_info({:updated, restaurant}, socket) do
    {:noreply, stream_insert(socket, :restaurants, restaurant)}
  end

  def handle_info({:deleted, restaurant}, socket) do
    {:noreply, stream_delete(socket, :restaurants, restaurant)}
  end
end
