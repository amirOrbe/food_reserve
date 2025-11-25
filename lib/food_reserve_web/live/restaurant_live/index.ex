defmodule FoodReserveWeb.RestaurantLive.Index do
  use FoodReserveWeb, :live_view

  alias FoodReserve.Restaurants
  alias FoodReserve.Accounts.User

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class={[
        "mx-auto px-4 sm:px-6 lg:px-8 py-8",
        if(User.restaurant_owner?(@current_scope.user), do: "max-w-7xl", else: "max-w-5xl")
      ]}>
        <.header>
          {if User.restaurant_owner?(@current_scope.user),
            do: "Mis Restaurantes",
            else: "Restaurantes"}
          <:actions>
            <.button
              :if={User.restaurant_owner?(@current_scope.user)}
              variant="primary"
              navigate={~p"/restaurants/new"}
            >
              <.icon name="hero-plus" /> Nuevo Restaurante
            </.button>
          </:actions>
        </.header>

        <div class="mt-8">
          <%= if @restaurants_count == 0 do %>
            <div class="text-center py-12 bg-white rounded-lg shadow-sm">
              <div class="mx-auto w-12 h-12 bg-gray-100 rounded-full flex items-center justify-center mb-4">
                <.icon name="hero-building-storefront" class="w-6 h-6 text-gray-400" />
              </div>
              <h3 class="text-lg font-medium text-gray-900 mb-2">
                {if User.restaurant_owner?(@current_scope.user),
                  do: "No tienes restaurantes",
                  else: "No has visitado ningún restaurante aun"}
              </h3>
              <p class="text-gray-500 mb-6">
                {if User.restaurant_owner?(@current_scope.user),
                  do: "Comienza creando tu primer restaurante",
                  else: "Vuelve pronto para descubrir nuevos lugares"}
              </p>
              <.button
                :if={User.restaurant_owner?(@current_scope.user)}
                variant="primary"
                navigate={~p"/restaurants/new"}
              >
                <.icon name="hero-plus" /> Crear mi primer restaurante
              </.button>
            </div>
          <% else %>
            <div class="bg-white shadow-sm rounded-lg overflow-hidden">
              <.table
                id="restaurants"
                rows={@streams.restaurants}
                row_click={fn {_id, restaurant} -> JS.navigate(~p"/restaurants/#{restaurant}") end}
              >
                <:col :let={{_id, restaurant}} label="Nombre">{restaurant.name}</:col>
                <:col :let={{_id, restaurant}} label="Descripción">{restaurant.description}</:col>
                <:col :let={{_id, restaurant}} label="Dirección">{restaurant.address}</:col>
                <:col :let={{_id, restaurant}} label="Teléfono">{restaurant.phone_number}</:col>
                <:col :let={{_id, restaurant}} label="Tipo de Cocina">{restaurant.cuisine_type}</:col>
                <:action :let={{_id, restaurant}}>
                  <div class="sr-only">
                    <.link navigate={~p"/restaurants/#{restaurant}"}>Ver</.link>
                  </div>
                  <.link
                    :if={User.restaurant_owner?(@current_scope.user)}
                    navigate={~p"/restaurants/#{restaurant}/edit"}
                  >
                    Editar
                  </.link>
                </:action>
                <:action :let={{id, restaurant}}>
                  <.link
                    :if={User.restaurant_owner?(@current_scope.user)}
                    phx-click={JS.push("delete", value: %{id: restaurant.id}) |> hide("##{id}")}
                    data-confirm="¿Estás seguro?"
                  >
                    Eliminar
                  </.link>
                </:action>
              </.table>
            </div>
          <% end %>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    scope = socket.assigns.current_scope

    if connected?(socket) do
      Restaurants.subscribe_restaurants(scope)
    end

    page_title =
      if User.restaurant_owner?(scope.user), do: "Mis Restaurantes", else: "Restaurantes"

    restaurants = Restaurants.list_restaurants(scope)

    {:ok,
     socket
     |> assign(:page_title, page_title)
     |> assign(:restaurants_count, length(restaurants))
     |> stream(:restaurants, restaurants)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    scope = socket.assigns.current_scope
    restaurant = Restaurants.get_restaurant!(scope, id)
    {:ok, _} = Restaurants.delete_restaurant(scope, restaurant)

    {:noreply,
     socket
     |> stream_delete(:restaurants, restaurant)
     |> assign(:restaurants_count, socket.assigns.restaurants_count - 1)}
  end

  @impl true
  def handle_info({:created, restaurant}, socket) do
    {:noreply,
     socket
     |> stream_insert(:restaurants, restaurant)
     |> assign(:restaurants_count, socket.assigns.restaurants_count + 1)}
  end

  def handle_info({:updated, restaurant}, socket) do
    {:noreply, stream_insert(socket, :restaurants, restaurant)}
  end

  def handle_info({:deleted, restaurant}, socket) do
    {:noreply,
     socket
     |> stream_delete(:restaurants, restaurant)
     |> assign(:restaurants_count, socket.assigns.restaurants_count - 1)}
  end
end
