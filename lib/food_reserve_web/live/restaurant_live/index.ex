defmodule FoodReserveWeb.RestaurantLive.Index do
  use FoodReserveWeb, :live_view
  import FoodReserveWeb.LiveHelpers

  alias FoodReserve.Restaurants
  alias FoodReserve.Reservations
  alias FoodReserve.Accounts.User

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app
      flash={@flash}
      current_scope={@current_scope}
      unread_notifications_count={@unread_notifications_count}
    >
      <div class={[
        "mx-auto px-4 sm:px-6 lg:px-8 py-8",
        if(User.restaurant_owner?(@current_scope.user), do: "max-w-7xl", else: "max-w-5xl")
      ]}>
        <.header>
          {@page_title}
          <:actions>
            <%= if @user_type == :restaurant_owner do %>
              <.button
                variant="primary"
                navigate={~p"/restaurants/new"}
              >
                <.icon name="hero-plus" /> Nuevo Restaurante
              </.button>
            <% else %>
              <.link
                navigate={~p"/my-reservations"}
                class="inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-lg text-gray-700 bg-white hover:bg-gray-50"
              >
                <.icon name="hero-list-bullet" class="w-4 h-4 mr-2" /> Ver Todas las Reservas
              </.link>
            <% end %>
          </:actions>
        </.header>

        <div class="mt-8">
          <%= if @user_type == :restaurant_owner do %>
            <!-- Vista para dueños de restaurantes -->
            <%= if @restaurants_count == 0 do %>
              <div class="text-center py-12 bg-white rounded-lg shadow-sm">
                <div class="mx-auto w-12 h-12 bg-gray-100 rounded-full flex items-center justify-center mb-4">
                  <.icon name="hero-building-storefront" class="w-6 h-6 text-gray-400" />
                </div>
                <h3 class="text-lg font-medium text-gray-900 mb-2">
                  No tienes restaurantes
                </h3>
                <p class="text-gray-500 mb-6">
                  Comienza creando tu primer restaurante
                </p>
                <.button
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
                  <:col :let={{_id, restaurant}} label="Tipo de Cocina">
                    {restaurant.cuisine_type}
                  </:col>
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
          <% else %>
            <!-- Vista para clientes: restaurantes con reservas -->
            <%= if @restaurants_count == 0 do %>
              <div class="text-center py-12 bg-white rounded-lg shadow-sm">
                <div class="mx-auto w-12 h-12 bg-gray-100 rounded-full flex items-center justify-center mb-4">
                  <.icon name="hero-calendar-days" class="w-6 h-6 text-gray-400" />
                </div>
                <h3 class="text-lg font-medium text-gray-900 mb-2">
                  No tienes reservas aún
                </h3>
                <p class="text-gray-500 mb-6">
                  Explora restaurantes y haz tu primera reserva
                </p>
                <.link
                  navigate={~p"/"}
                  class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-lg text-white bg-orange-600 hover:bg-orange-700"
                >
                  <.icon name="hero-magnifying-glass" class="w-4 h-4 mr-2" /> Explorar Restaurantes
                </.link>
              </div>
            <% else %>
              <div class="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
                <%= for restaurant_data <- @user_restaurants do %>
                  <div class="bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden hover:shadow-md transition-shadow duration-200">
                    <!-- Restaurant Header -->
                    <div class="p-6">
                      <div class="flex items-center justify-between mb-4">
                        <h3 class="text-lg font-semibold text-gray-900">
                          {restaurant_data.restaurant.name}
                        </h3>
                        <span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-orange-100 text-orange-800">
                          {restaurant_data.restaurant.cuisine_type}
                        </span>
                      </div>

                      <p class="text-sm text-gray-600 mb-4">
                        {restaurant_data.restaurant.address}
                      </p>
                      
    <!-- Latest Reservation Info -->
                      <div class="bg-gray-50 rounded-lg p-4 mb-4">
                        <div class="flex items-center justify-between mb-2">
                          <span class="text-sm font-medium text-gray-700">Última reserva:</span>
                          <span class={[
                            "inline-flex items-center px-2 py-1 rounded-full text-xs font-medium",
                            case restaurant_data.latest_reservation.status do
                              "pending" -> "bg-yellow-100 text-yellow-800"
                              "confirmed" -> "bg-green-100 text-green-800"
                              "cancelled" -> "bg-red-100 text-red-800"
                              "completed" -> "bg-blue-100 text-blue-800"
                              _ -> "bg-gray-100 text-gray-800"
                            end
                          ]}>
                            {FoodReserve.Reservations.Reservation.status_name(
                              restaurant_data.latest_reservation.status
                            )}
                          </span>
                        </div>
                        <div class="text-sm text-gray-600">
                          <div class="flex items-center mb-1">
                            <.icon name="hero-calendar-days" class="w-4 h-4 mr-2" />
                            {Calendar.strftime(
                              restaurant_data.latest_reservation.reservation_date,
                              "%d/%m/%Y"
                            )}
                          </div>
                          <div class="flex items-center mb-1">
                            <.icon name="hero-clock" class="w-4 h-4 mr-2" />
                            {Calendar.strftime(
                              restaurant_data.latest_reservation.reservation_time,
                              "%H:%M"
                            )}
                          </div>
                          <div class="flex items-center">
                            <.icon name="hero-user-group" class="w-4 h-4 mr-2" />
                            {restaurant_data.latest_reservation.party_size} personas
                          </div>
                        </div>
                      </div>
                      
    <!-- Stats and Actions -->
                      <div class="flex items-center justify-between">
                        <div class="text-sm text-gray-500">
                          <span class="font-medium">{restaurant_data.total_reservations}</span>
                          {if restaurant_data.total_reservations == 1, do: "reserva", else: "reservas"} total
                        </div>

                        <div class="flex gap-2">
                          <.link
                            navigate={~p"/restaurants/#{restaurant_data.restaurant}"}
                            class="inline-flex items-center px-3 py-1 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50"
                          >
                            Ver
                          </.link>
                          <.link
                            navigate={~p"/restaurants/#{restaurant_data.restaurant}/reserve"}
                            class="inline-flex items-center px-3 py-1 border border-transparent text-sm font-medium rounded-md text-white bg-green-600 hover:bg-green-700"
                          >
                            Reservar
                          </.link>
                        </div>
                      </div>
                    </div>
                  </div>
                <% end %>
              </div>
            <% end %>
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

    if User.restaurant_owner?(scope.user) do
      # Para dueños de restaurantes: mostrar sus restaurantes
      page_title = "Mis Restaurantes"
      restaurants = Restaurants.list_restaurants(scope)

      {:ok,
       socket
       |> assign(:page_title, page_title)
       |> assign(:user_type, :restaurant_owner)
       |> assign(:restaurants_count, length(restaurants))
       |> stream(:restaurants, restaurants)}
    else
      # Para clientes: mostrar restaurantes donde han hecho reservas
      page_title = "Mis Reservas por Restaurante"
      user_restaurants = Reservations.get_user_restaurants_with_reservations(scope)

      {:ok,
       socket
       |> assign(:page_title, page_title)
       |> assign(:user_type, :customer)
       |> assign(:user_restaurants, user_restaurants)
       |> assign(:restaurants_count, length(user_restaurants))}
    end
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

  # Handle real-time notifications
  handle_notifications()
end
