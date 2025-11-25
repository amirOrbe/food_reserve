defmodule FoodReserveWeb.RestaurantLive.Show do
  use FoodReserveWeb, :live_view

  alias FoodReserve.Restaurants

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <!-- Header Card -->
        <div class="bg-white shadow-sm rounded-lg border border-gray-200 mb-6">
          <div class="px-6 py-8 sm:px-8">
            <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between">
              <div class="mb-4 sm:mb-0">
                <h1 class="text-3xl font-bold text-gray-900 mb-2">{@restaurant.name}</h1>
                <p class="text-gray-600">Información detallada de tu restaurante</p>
              </div>

              <div class="flex flex-col sm:flex-row gap-3">
                <.link
                  navigate={~p"/"}
                  class="inline-flex justify-center items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-lg text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-orange-500 transition-colors duration-200"
                >
                  <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M10 19l-7-7m0 0l7-7m-7 7h18"
                    />
                  </svg>
                  Volver
                </.link>

                <%= if @current_scope && @current_scope.user && @current_scope.user.id == @restaurant.user_id do %>
                  <.link
                    navigate={~p"/restaurants/#{@restaurant}/edit?return_to=show"}
                    class="inline-flex justify-center items-center px-4 py-2 border border-transparent text-sm font-medium rounded-lg text-white bg-orange-600 hover:bg-orange-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-orange-500 transition-colors duration-200"
                  >
                    <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"
                      />
                    </svg>
                    Editar
                  </.link>
                <% end %>
              </div>
            </div>
          </div>
        </div>
        
    <!-- Restaurant Details Card -->
        <div class="bg-white shadow-sm rounded-lg border border-gray-200">
          <div class="px-6 py-8 sm:px-8">
            <h2 class="text-xl font-semibold text-gray-900 mb-6">Detalles del Restaurante</h2>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div class="space-y-6">
                <div>
                  <dt class="text-sm font-medium text-gray-500 mb-1">Nombre</dt>
                  <dd class="text-base text-gray-900">{@restaurant.name}</dd>
                </div>

                <div>
                  <dt class="text-sm font-medium text-gray-500 mb-1">Tipo de Cocina</dt>
                  <dd class="text-base text-gray-900">
                    <span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-orange-100 text-orange-800">
                      {@restaurant.cuisine_type}
                    </span>
                  </dd>
                </div>

                <div>
                  <dt class="text-sm font-medium text-gray-500 mb-1">Teléfono</dt>
                  <dd class="text-base text-gray-900">
                    <a
                      href={"tel:#{@restaurant.phone_number}"}
                      class="text-orange-600 hover:text-orange-700 font-medium"
                    >
                      {@restaurant.phone_number}
                    </a>
                  </dd>
                </div>
              </div>

              <div class="space-y-6">
                <div>
                  <dt class="text-sm font-medium text-gray-500 mb-1">Dirección</dt>
                  <dd class="text-base text-gray-900">{@restaurant.address}</dd>
                </div>

                <div>
                  <dt class="text-sm font-medium text-gray-500 mb-1">Descripción</dt>
                  <dd class="text-base text-gray-900 leading-relaxed">{@restaurant.description}</dd>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    restaurant = Restaurants.get_public_restaurant!(id)

    # Solo suscribirse si el usuario está autenticado y es el dueño del restaurante
    if connected?(socket) && socket.assigns.current_scope &&
         socket.assigns.current_scope.user &&
         socket.assigns.current_scope.user.id == restaurant.user_id do
      Restaurants.subscribe_restaurants(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Ver Restaurante")
     |> assign(:restaurant, restaurant)}
  end

  @impl true
  def handle_info(
        {:updated, %FoodReserve.Restaurants.Restaurant{id: id} = restaurant},
        %{assigns: %{restaurant: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :restaurant, restaurant)}
  end

  def handle_info(
        {:deleted, %FoodReserve.Restaurants.Restaurant{id: id}},
        %{assigns: %{restaurant: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "El restaurante actual fue eliminado.")
     |> push_navigate(to: ~p"/restaurants")}
  end

  def handle_info({type, %FoodReserve.Restaurants.Restaurant{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
