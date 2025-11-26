defmodule FoodReserveWeb.RestaurantLive.Show do
  use FoodReserveWeb, :live_view
  import FoodReserveWeb.LiveHelpers

  alias FoodReserve.Restaurants
  alias FoodReserve.Menus
  alias FoodReserve.Reviews

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app
      flash={@flash}
      current_scope={@current_scope}
      unread_notifications_count={@unread_notifications_count}
    >
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

                <%= if @current_scope && @current_scope.user do %>
                  <%= if @current_scope.user.id == @restaurant.user_id do %>
                    <!-- Botón para dueños del restaurante -->
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
                  <% else %>
                    <!-- Botones para clientes -->
                    <div class="flex flex-col sm:flex-row gap-3">
                      <.link
                        navigate={~p"/restaurants/#{@restaurant}/reserve"}
                        class="inline-flex justify-center items-center px-4 py-2 border border-transparent text-sm font-medium rounded-lg text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500 transition-colors duration-200"
                      >
                        <.icon name="hero-calendar-days" class="w-4 h-4 mr-2" /> Hacer Reserva
                      </.link>

                      <.link
                        navigate={~p"/restaurants/#{@restaurant}/pickup"}
                        class="inline-flex justify-center items-center px-4 py-2 border border-transparent text-sm font-medium rounded-lg text-white bg-orange-600 hover:bg-orange-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-orange-500 transition-colors duration-200"
                      >
                        <.icon name="hero-shopping-bag" class="w-4 h-4 mr-2" /> Pedir para llevar
                      </.link>

                      <%= if @can_review do %>
                        <.link
                          navigate={~p"/restaurants/#{@restaurant}/review"}
                          class="inline-flex justify-center items-center px-4 py-2 border border-transparent text-sm font-medium rounded-lg text-white bg-yellow-600 hover:bg-yellow-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-yellow-500 transition-colors duration-200"
                        >
                          <.icon name="hero-star" class="w-4 h-4 mr-2" /> Calificar
                        </.link>
                      <% end %>
                    </div>
                  <% end %>
                <% else %>
                  <!-- Botón para usuarios no autenticados -->
                  <.link
                    href={~p"/users/log-in"}
                    class="inline-flex items-center px-4 py-2 border border-gray-300 shadow-sm text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-orange-500 transition-colors duration-200"
                  >
                    <svg
                      class="-ml-1 mr-2 h-4 w-4"
                      xmlns="http://www.w3.org/2000/svg"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke="currentColor"
                      aria-hidden="true"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M11 16l-4-4m0 0l4-4m-4 4h14m-5 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h7a3 3 0 013 3v1"
                      />
                    </svg>
                    Iniciar Sesión para Ordenar
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
        
    <!-- Menu Section -->
        <div class="bg-white shadow-sm rounded-lg border border-gray-200">
          <div class="px-6 py-8 sm:px-8">
            <div class="flex items-center justify-between mb-6">
              <h2 class="text-xl font-semibold text-gray-900">Menú</h2>
              <%= if @current_scope && @current_scope.user && @current_scope.user.id == @restaurant.user_id do %>
                <.link
                  navigate={~p"/restaurants/#{@restaurant}/menu"}
                  class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-orange-600 hover:bg-orange-700"
                >
                  <.icon name="hero-plus" class="w-4 h-4 mr-2" /> Gestionar Menú
                </.link>
              <% end %>
            </div>

            <%= if Enum.empty?(@menu_items) do %>
              <div class="text-center py-12">
                <div class="mx-auto w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mb-4">
                  <.icon name="hero-document-text" class="w-8 h-8 text-gray-400" />
                </div>
                <h3 class="text-lg font-medium text-gray-900 mb-2">
                  Menú no disponible
                </h3>
                <p class="text-gray-500">
                  <%= if @current_scope && @current_scope.user && @current_scope.user.id == @restaurant.user_id do %>
                    Agrega elementos a tu menú para que los clientes puedan verlos.
                  <% else %>
                    Este restaurante aún no ha publicado su menú.
                  <% end %>
                </p>
              </div>
            <% else %>
              <div class="space-y-8">
                <%= for {category, items} <- @grouped_menu_items do %>
                  <div>
                    <h3 class="text-lg font-medium text-gray-900 mb-4 pb-2 border-b border-gray-200">
                      {category}
                    </h3>
                    <div class="grid gap-4 md:grid-cols-2">
                      <%= for item <- items do %>
                        <div class="flex justify-between items-start p-4 bg-gray-50 rounded-lg">
                          <div class="flex-1">
                            <h4 class="font-medium text-gray-900 mb-1">{item.name}</h4>
                            <p class="text-sm text-gray-600 mb-2">{item.description}</p>
                            <%= unless item.available do %>
                              <span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-red-100 text-red-800">
                                No disponible
                              </span>
                            <% end %>
                          </div>
                          <div class="ml-4 flex-shrink-0">
                            <span class="text-lg font-semibold text-orange-600">
                              ${:erlang.float_to_binary(Decimal.to_float(item.price), decimals: 2)}
                            </span>
                          </div>
                        </div>
                      <% end %>
                    </div>
                  </div>
                <% end %>
              </div>
            <% end %>
          </div>
        </div>
        
    <!-- Working Hours Section -->
        <div class="bg-white shadow-sm rounded-lg border border-gray-200">
          <div class="px-6 py-8 sm:px-8">
            <div class="flex items-center justify-between mb-6">
              <h2 class="text-xl font-semibold text-gray-900">Horarios de Atención</h2>
              <%= if @current_scope && @current_scope.user && @current_scope.user.id == @restaurant.user_id do %>
                <.link
                  navigate={~p"/restaurants/#{@restaurant}/hours"}
                  class="inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50"
                >
                  <.icon name="hero-clock" class="w-4 h-4 mr-2" /> Gestionar Horarios
                </.link>

                <.link
                  navigate={~p"/restaurants/#{@restaurant}/reservations"}
                  class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-green-600 hover:bg-green-700"
                >
                  <.icon name="hero-calendar-days" class="w-4 h-4 mr-2" /> Gestionar Reservas
                </.link>
              <% end %>
            </div>

            <%= if Enum.empty?(@working_hours) do %>
              <div class="text-center py-12">
                <div class="mx-auto w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mb-4">
                  <.icon name="hero-clock" class="w-8 h-8 text-gray-400" />
                </div>
                <h3 class="text-lg font-medium text-gray-900 mb-2">
                  Horarios no disponibles
                </h3>
                <p class="text-gray-500">
                  <%= if @current_scope && @current_scope.user && @current_scope.user.id == @restaurant.user_id do %>
                    Configura los horarios de atención de tu restaurante.
                  <% else %>
                    Este restaurante aún no ha configurado sus horarios.
                  <% end %>
                </p>
              </div>
            <% else %>
              <div class="grid gap-3">
                <%= for working_hour <- @working_hours do %>
                  <div class="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
                    <div class="flex items-center">
                      <div class="w-20 text-sm font-medium text-gray-900">
                        {FoodReserve.Restaurants.WorkingHour.day_name(working_hour.day_of_week)}
                      </div>
                    </div>
                    <div class="flex items-center">
                      <%= if working_hour.is_closed do %>
                        <span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-red-100 text-red-800">
                          <.icon name="hero-x-mark" class="w-4 h-4 mr-1" /> Cerrado
                        </span>
                      <% else %>
                        <div class="flex items-center text-sm text-gray-600">
                          <.icon name="hero-clock" class="w-4 h-4 mr-2 text-green-500" />
                          <span class="font-medium">
                            {Calendar.strftime(working_hour.open_time, "%H:%M")} - {Calendar.strftime(
                              working_hour.close_time,
                              "%H:%M"
                            )}
                          </span>
                        </div>
                      <% end %>
                    </div>
                  </div>
                <% end %>
              </div>
              
    <!-- Current Status -->
              <div class="mt-6 pt-6 border-t border-gray-200">
                <div class="flex items-center justify-center">
                  <%= case get_current_status(@working_hours) do %>
                    <% {:open, closes_at} -> %>
                      <div class="flex items-center text-green-600">
                        <div class="w-3 h-3 bg-green-500 rounded-full mr-2 animate-pulse"></div>
                        <span class="font-medium">Abierto ahora</span>
                        <span class="ml-2 text-sm text-gray-500">
                          • Cierra a las {Calendar.strftime(closes_at, "%H:%M")}
                        </span>
                      </div>
                    <% {:closed, opens_at} -> %>
                      <div class="flex items-center text-red-600">
                        <div class="w-3 h-3 bg-red-500 rounded-full mr-2"></div>
                        <span class="font-medium">Cerrado</span>
                        <%= if opens_at do %>
                          <span class="ml-2 text-sm text-gray-500">
                            • Abre a las {Calendar.strftime(opens_at, "%H:%M")}
                          </span>
                        <% end %>
                      </div>
                    <% :unknown -> %>
                      <div class="flex items-center text-gray-500">
                        <div class="w-3 h-3 bg-gray-400 rounded-full mr-2"></div>
                        <span>Estado no disponible</span>
                      </div>
                  <% end %>
                </div>
              </div>
            <% end %>
          </div>
        </div>
        
    <!-- Sección de Reseñas -->
        <div class="bg-white shadow-sm rounded-lg border border-gray-200 mt-6">
          <div class="px-6 py-8 sm:px-8">
            <div class="flex items-center justify-between mb-6">
              <h2 class="text-xl font-semibold text-gray-900">Reseñas y Calificaciones</h2>
              <%= if @review_stats.total_reviews > 0 do %>
                <div class="flex items-center">
                  <div class="flex items-center mr-3">
                    <%= for i <- 1..5 do %>
                      <.icon
                        name="hero-star"
                        class={
                          Enum.join(
                            [
                              "w-5 h-5",
                              if(i <= @review_stats.average_overall_rating,
                                do: "text-yellow-400",
                                else: "text-gray-300"
                              )
                            ],
                            " "
                          )
                        }
                      />
                    <% end %>
                  </div>
                  <span class="text-lg font-bold text-gray-900 mr-2">
                    {@review_stats.average_overall_rating}
                  </span>
                  <span class="text-sm text-gray-600">
                    ({@review_stats.total_reviews} {if @review_stats.total_reviews == 1,
                      do: "reseña",
                      else: "reseñas"})
                  </span>
                </div>
              <% end %>
            </div>

            <%= if @review_stats.total_reviews > 0 do %>
              <!-- Estadísticas detalladas -->
              <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8 p-4 bg-gray-50 rounded-lg">
                <div class="text-center">
                  <div class="text-2xl font-bold text-orange-600">
                    {@review_stats.average_food_rating}
                  </div>
                  <div class="text-sm text-gray-600">Comida</div>
                  <div class="flex justify-center mt-1">
                    <%= for i <- 1..5 do %>
                      <.icon
                        name="hero-star"
                        class={
                          Enum.join(
                            [
                              "w-4 h-4",
                              if(i <= @review_stats.average_food_rating,
                                do: "text-orange-400",
                                else: "text-gray-300"
                              )
                            ],
                            " "
                          )
                        }
                      />
                    <% end %>
                  </div>
                  <!-- ... -->
                  <div class="text-sm text-gray-600">Servicio</div>
                  <div class="flex justify-center mt-1">
                    <%= for i <- 1..5 do %>
                      <.icon
                        name="hero-star"
                        class={
                          Enum.join(
                            [
                              "w-4 h-4",
                              if(i <= @review_stats.average_service_rating,
                                do: "text-blue-400",
                                else: "text-gray-300"
                              )
                            ],
                            " "
                          )
                        }
                      />
                    <% end %>
                  </div>
                </div>
                <div class="text-center">
                  <div class="text-2xl font-bold text-blue-600">
                    {@review_stats.average_service_rating}
                  </div>
                  <div class="text-sm text-gray-600">Servicio</div>
                  <div class="flex justify-center mt-1">
                    <%= for i <- 1..5 do %>
                      <.icon
                        name="hero-star"
                        class={
                          Enum.join(
                            [
                              "w-4 h-4",
                              if(i <= @review_stats.average_service_rating,
                                do: "text-blue-400",
                                else: "text-gray-300"
                              )
                            ],
                            " "
                          )
                        }
                      />
                    <% end %>
                  </div>
                </div>
              </div>
              
    <!-- Lista de reseñas -->
              <div class="space-y-6">
                <%= for review <- @reviews do %>
                  <div class="border-b border-gray-200 pb-6 last:border-b-0">
                    <div class="flex items-start justify-between mb-3">
                      <div class="flex items-center">
                        <div class="w-10 h-10 bg-gray-300 rounded-full flex items-center justify-center mr-3">
                          <span class="text-sm font-medium text-gray-700">
                            {String.first(review.user.name)}
                          </span>
                        </div>
                        <div>
                          <div class="font-medium text-gray-900">{review.user.name}</div>
                          <div class="text-sm text-gray-500">
                            {Calendar.strftime(review.inserted_at, "%d/%m/%Y")}
                          </div>
                        </div>
                      </div>
                      <div class="flex items-center">
                        <span class="text-lg font-bold text-gray-900 mr-2">
                          {Float.round((review.food_rating + review.service_rating) / 2, 1)}
                        </span>
                        <div class="flex">
                          <%= for i <- 1..5 do %>
                            <.icon
                              name="hero-star"
                              class={
                                Enum.join(
                                  [
                                    "w-4 h-4",
                                    if(i <= (review.food_rating + review.service_rating) / 2,
                                      do: "text-yellow-400",
                                      else: "text-gray-300"
                                    )
                                  ],
                                  " "
                                )
                              }
                            />
                          <% end %>
                        </div>
                      </div>
                    </div>

                    <div class="flex gap-4 mb-3 text-sm">
                      <div class="flex items-center">
                        <span class="text-gray-600 mr-1">Comida:</span>
                        <div class="flex">
                          <%= for i <- 1..5 do %>
                            <.icon
                              name="hero-star"
                              class={
                                Enum.join(
                                  [
                                    "w-3 h-3",
                                    if(i <= review.food_rating,
                                      do: "text-orange-400",
                                      else: "text-gray-300"
                                    )
                                  ],
                                  " "
                                )
                              }
                            />
                          <% end %>
                        </div>
                        <span class="ml-1 text-gray-900">{review.food_rating}</span>
                      </div>
                      <div class="flex items-center">
                        <span class="text-gray-600 mr-1">Servicio:</span>
                        <div class="flex">
                          <%= for i <- 1..5 do %>
                            <.icon
                              name="hero-star"
                              class={
                                Enum.join(
                                  [
                                    "w-3 h-3",
                                    if(i <= review.service_rating,
                                      do: "text-blue-400",
                                      else: "text-gray-300"
                                    )
                                  ],
                                  " "
                                )
                              }
                            />
                          <% end %>
                        </div>
                        <span class="ml-1 text-gray-900">{review.service_rating}</span>
                      </div>
                    </div>

                    <%= if review.comment && review.comment != "" do %>
                      <p class="text-gray-700 leading-relaxed">{review.comment}</p>
                    <% end %>
                  </div>
                <% end %>
              </div>
            <% else %>
              <div class="text-center py-12">
                <.icon name="hero-star" class="w-12 h-12 text-gray-300 mx-auto mb-4" />
                <h3 class="text-lg font-medium text-gray-900 mb-2">Aún no hay reseñas</h3>
                <p class="text-gray-600">Sé el primero en calificar este restaurante.</p>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    restaurant = Restaurants.get_public_restaurant!(id)
    menu_items = Menus.list_menu_items_by_restaurant(restaurant.id)
    working_hours = Restaurants.get_public_working_hours(restaurant.id)
    reviews = Reviews.list_restaurant_reviews(restaurant.id)
    review_stats = Reviews.get_restaurant_review_stats(restaurant.id)

    # Verificar si el usuario puede dejar una reseña
    can_review =
      if socket.assigns.current_scope do
        Reviews.can_user_review_restaurant?(socket.assigns.current_scope, restaurant.id)
      else
        false
      end

    # Solo suscribirse si el usuario está autenticado y es el dueño del restaurante
    if connected?(socket) && socket.assigns.current_scope &&
         socket.assigns.current_scope.user &&
         socket.assigns.current_scope.user.id == restaurant.user_id do
      Restaurants.subscribe_restaurants(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Ver Restaurante")
     |> assign(:restaurant, restaurant)
     |> assign(:menu_items, menu_items)
     |> assign(:grouped_menu_items, group_menu_items_by_category(menu_items))
     |> assign(:working_hours, working_hours)
     |> assign(:reviews, reviews)
     |> assign(:review_stats, review_stats)
     |> assign(:can_review, can_review)}
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

  defp group_menu_items_by_category(menu_items) do
    menu_items
    |> Enum.group_by(fn item -> item.category || "Sin categoría" end)
    |> Enum.sort_by(fn {category, _items} -> category end)
  end

  defp get_current_status(working_hours) do
    if Enum.empty?(working_hours) do
      :unknown
    else
      now = DateTime.utc_now() |> DateTime.add(-6, :hour)
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
