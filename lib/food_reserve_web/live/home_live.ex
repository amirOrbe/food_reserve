defmodule FoodReserveWeb.HomeLive do
  use FoodReserveWeb, :live_view
  import FoodReserveWeb.LiveHelpers

  alias FoodReserve.Restaurants

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app
      flash={@flash}
      current_scope={@current_scope}
      unread_notifications_count={@unread_notifications_count}
    >
      <div class="bg-gray-50">
        <section class="bg-white">
          <div class="container mx-auto px-4 sm:px-6 lg:px-8 py-20 text-center">
            <h1 class="text-4xl md:text-5xl font-extrabold text-gray-900 leading-tight mb-4">
              Tu próxima comida favorita, <span class="text-orange-500">a un clic de distancia.</span>
            </h1>
            <p class="text-lg text-gray-600 mb-8 max-w-2xl mx-auto">
              Descubre y reserva en los mejores restaurantes locales. Pide por adelantado y ten tu comida lista cuando llegues.
            </p>
            <div class="max-w-xl mx-auto">
              <div class="flex items-center bg-white rounded-full shadow-md p-2">
                <input
                  type="text"
                  placeholder="Busca un plato o restaurante..."
                  class="w-full bg-transparent border-none focus:ring-0 text-lg px-4"
                />
                <.button variant="primary" class="rounded-full">Buscar</.button>
              </div>
            </div>
          </div>
        </section>

        <section class="py-16">
          <div class="container mx-auto px-4 sm:px-6 lg:px-8">
            <h2 class="text-3xl font-bold text-center text-gray-800 mb-10">
              Restaurantes Destacados
            </h2>

            <%= if Enum.empty?(@restaurants) do %>
              <div class="text-center py-12">
                <div class="mx-auto w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mb-4">
                  <.icon name="hero-building-storefront" class="w-8 h-8 text-gray-400" />
                </div>
                <h3 class="text-lg font-medium text-gray-900 mb-2">
                  Aún no hay restaurantes registrados
                </h3>
                <p class="text-gray-500 mb-6">
                  ¡Sé el primero en registrar tu restaurante y aparecer aquí!
                </p>
                <%= if @current_scope && @current_scope.user do %>
                  <.link
                    navigate={~p"/users/register"}
                    class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-orange-600 hover:bg-orange-700"
                  >
                    Registrar Restaurante
                  </.link>
                <% else %>
                  <.link
                    navigate={~p"/users/register"}
                    class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-orange-600 hover:bg-orange-700"
                  >
                    Comenzar Ahora
                  </.link>
                <% end %>
              </div>
            <% else %>
              <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
                <%= for restaurant <- @restaurants do %>
                  <div class="bg-white rounded-2xl shadow-lg overflow-hidden transform hover:-translate-y-1 transition-transform duration-300">
                    <!-- Imagen placeholder con gradiente -->
                    <div class="w-full h-48 bg-gradient-to-br from-orange-400 to-orange-600 flex items-center justify-center">
                      <div class="text-center text-white">
                        <.icon name="hero-building-storefront" class="w-12 h-12 mx-auto mb-2" />
                        <p class="text-sm font-medium">Foto próximamente</p>
                      </div>
                    </div>

                    <div class="p-6">
                      <div class="flex items-center justify-between mb-2">
                        <h3 class="text-xl font-bold text-gray-900">{restaurant.name}</h3>
                        <%= case restaurant.current_status do %>
                          <% {:open, _closes_at} -> %>
                            <span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800">
                              <div class="w-2 h-2 bg-green-500 rounded-full mr-1 animate-pulse"></div>
                              Abierto
                            </span>
                          <% {:closed, _opens_at} -> %>
                            <span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-red-100 text-red-800">
                              <div class="w-2 h-2 bg-red-500 rounded-full mr-1"></div>
                              Cerrado
                            </span>
                          <% :unknown -> %>
                            <span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-gray-100 text-gray-600">
                              <div class="w-2 h-2 bg-gray-400 rounded-full mr-1"></div>
                              Sin horarios
                            </span>
                        <% end %>
                      </div>
                      <p class="text-gray-600 mb-2">
                        <span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-orange-100 text-orange-800">
                          {restaurant.cuisine_type}
                        </span>
                      </p>
                      <p class="text-gray-600 mb-4 text-sm line-clamp-2">{restaurant.description}</p>

                      <div class="flex items-center justify-between">
                        <div class="flex items-center text-sm text-gray-500">
                          <.icon name="hero-map-pin" class="w-4 h-4 mr-1" />
                          <span class="truncate">{restaurant.address}</span>
                        </div>
                        <.link
                          navigate={~p"/restaurants/#{restaurant}"}
                          class="inline-flex items-center px-3 py-1 border border-transparent text-sm font-medium rounded-md text-orange-600 bg-orange-50 hover:bg-orange-100"
                        >
                          Ver más
                        </.link>
                      </div>

                      <%= if restaurant.phone_number do %>
                        <div class="mt-3 pt-3 border-t border-gray-100">
                          <div class="flex items-center text-sm text-gray-500">
                            <.icon name="hero-phone" class="w-4 h-4 mr-1" />
                            <a
                              href={"tel:#{restaurant.phone_number}"}
                              class="text-orange-600 hover:text-orange-700"
                            >
                              {restaurant.phone_number}
                            </a>
                          </div>
                        </div>
                      <% end %>
                    </div>
                  </div>
                <% end %>
              </div>

              <%= if length(@restaurants) >= 6 do %>
                <div class="text-center mt-12">
                  <.link
                    navigate={~p"/restaurants"}
                    class="inline-flex items-center px-6 py-3 border border-transparent text-base font-medium rounded-md text-white bg-orange-600 hover:bg-orange-700"
                  >
                    Ver Todos los Restaurantes <.icon name="hero-arrow-right" class="ml-2 w-5 h-5" />
                  </.link>
                </div>
              <% end %>
            <% end %>
          </div>
        </section>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    # Obtener los primeros 6 restaurantes para mostrar en la página de inicio
    restaurants = Restaurants.list_public_restaurants(limit: 6)

    # Cargar horarios para cada restaurante y calcular su estado
    restaurants_with_status =
      Enum.map(restaurants, fn restaurant ->
        working_hours = Restaurants.get_public_working_hours(restaurant.id)
        status = get_current_status(working_hours)
        Map.put(restaurant, :current_status, status)
      end)

    {:ok,
     socket
     |> assign(:page_title, "Inicio")
     |> assign(:restaurants, restaurants_with_status)}
  end

  defp get_current_status(working_hours) do
    if Enum.empty?(working_hours) do
      :unknown
    else
      # Usar UTC y asumir zona horaria local para simplicidad
      now = DateTime.utc_now()
      current_day = get_current_day_of_week(now)
      current_time = DateTime.to_time(now)

      case Enum.find(working_hours, fn wh -> wh.day_of_week == current_day end) do
        nil ->
          :unknown

        %{is_closed: true} ->
          {:closed, get_next_opening_time(working_hours, current_day)}

        working_hour ->
          if (working_hour.open_time && working_hour.close_time &&
                Time.compare(current_time, working_hour.open_time) != :lt) and
               Time.compare(current_time, working_hour.close_time) == :lt do
            {:open, working_hour.close_time}
          else
            {:closed, get_next_opening_time(working_hours, current_day)}
          end
      end
    end
  end

  defp get_current_day_of_week(datetime) do
    case Date.day_of_week(DateTime.to_date(datetime)) do
      1 -> "monday"
      2 -> "tuesday"
      3 -> "wednesday"
      4 -> "thursday"
      5 -> "friday"
      6 -> "saturday"
      7 -> "sunday"
    end
  end

  defp get_next_opening_time(working_hours, current_day) do
    days_order = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]
    current_index = Enum.find_index(days_order, &(&1 == current_day))

    # Buscar el próximo día abierto
    Enum.reduce_while(1..7, nil, fn offset, _acc ->
      next_index = rem(current_index + offset, 7)
      next_day = Enum.at(days_order, next_index)

      case Enum.find(working_hours, fn wh ->
             wh.day_of_week == next_day and not wh.is_closed and wh.open_time
           end) do
        nil -> {:cont, nil}
        working_hour -> {:halt, working_hour.open_time}
      end
    end)
  end

  # Handle real-time notifications
  handle_notifications()
end
