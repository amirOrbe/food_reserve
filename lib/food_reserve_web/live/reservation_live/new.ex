defmodule FoodReserveWeb.ReservationLive.New do
  use FoodReserveWeb, :live_view
  import FoodReserveWeb.LiveHelpers

  alias FoodReserve.Restaurants
  alias FoodReserve.Reservations
  alias FoodReserve.Reservations.Reservation

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app
      flash={@flash}
      current_scope={@current_scope}
      unread_notifications_count={@unread_notifications_count}
    >
      <div class="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <!-- Header -->
        <div class="bg-white shadow-sm rounded-lg border border-gray-200 mb-6">
          <div class="px-6 py-8 sm:px-8">
            <div class="flex items-center justify-between">
              <div>
                <h1 class="text-3xl font-bold text-gray-900 mb-2">
                  Hacer Reserva
                </h1>
                <p class="text-gray-600">Restaurante: {@restaurant.name}</p>
              </div>
              <.link
                navigate={~p"/restaurants/#{@restaurant}"}
                class="inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-lg text-gray-700 bg-white hover:bg-gray-50"
              >
                <.icon name="hero-arrow-left" class="w-4 h-4 mr-2" /> Volver
              </.link>
            </div>
          </div>
        </div>
        
    <!-- Reservation Form -->
        <div class="bg-white shadow-sm rounded-lg border border-gray-200">
          <div class="px-6 py-8 sm:px-8">
            <.form
              for={@form}
              id="reservation-form"
              phx-submit="save"
              class="space-y-6"
            >
              <!-- Restaurant Info -->
              <div class="bg-orange-50 border border-orange-200 rounded-lg p-4 mb-6">
                <div class="flex items-center">
                  <.icon name="hero-building-storefront" class="w-5 h-5 text-orange-600 mr-2" />
                  <div>
                    <h3 class="font-medium text-orange-900">{@restaurant.name}</h3>
                    <p class="text-sm text-orange-700">{@restaurant.address}</p>
                  </div>
                </div>
              </div>
              
    <!-- Date and Time -->
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-6">
                <div>
                  <.input
                    field={@form[:reservation_date]}
                    type="date"
                    label="Fecha de la reserva"
                    min={Date.to_string(Date.utc_today())}
                    phx-change="date_changed"
                    required
                  />
                </div>

                <div>
                  <%= if @available_times && not Enum.empty?(@available_times) do %>
                    <label class="block text-sm font-medium text-gray-700 mb-1">
                      Hora de la reserva
                      <span class="text-xs text-green-600 font-normal">
                        ({length(@available_times)} horarios disponibles)
                      </span>
                    </label>
                    <select
                      name="reservation[reservation_time]"
                      id="reservation_reservation_time"
                      class="block w-full border-gray-300 rounded-md shadow-sm focus:ring-orange-500 focus:border-orange-500"
                      required
                    >
                      <option value="">Selecciona una hora</option>
                      <%= for time <- @available_times do %>
                        <option value={Time.to_string(time)}>
                          {Calendar.strftime(time, "%H:%M")}
                        </option>
                      <% end %>
                    </select>
                    <p class="mt-1 text-xs text-gray-500">
                      Los horarios mostrados están disponibles para reserva
                    </p>
                  <% else %>
                    <div class="block">
                      <label class="block text-sm font-medium text-gray-700 mb-1">
                        Hora de la reserva
                      </label>
                      <div class="p-3 bg-gray-100 border border-gray-300 rounded-md text-sm text-gray-500">
                        <%= if @selected_date do %>
                          <div class="flex items-center">
                            <.icon
                              name="hero-exclamation-triangle"
                              class="w-4 h-4 mr-2 text-amber-500"
                            /> No hay horarios disponibles para esta fecha
                          </div>
                          <p class="mt-1 text-xs">
                            Todos los horarios están reservados o el restaurante está cerrado
                          </p>
                        <% else %>
                          <div class="flex items-center">
                            <.icon name="hero-calendar-days" class="w-4 h-4 mr-2 text-blue-500" />
                            Selecciona una fecha para ver horarios disponibles
                          </div>
                        <% end %>
                      </div>
                    </div>
                  <% end %>
                </div>
              </div>
              
    <!-- Party Size -->
              <div>
                <.input
                  field={@form[:party_size]}
                  type="number"
                  label="Número de personas"
                  min="1"
                  max="20"
                  placeholder="¿Para cuántas personas?"
                  required
                />
              </div>
              
    <!-- Customer Information -->
              <div class="border-t border-gray-200 pt-6">
                <h3 class="text-lg font-medium text-gray-900 mb-4">Información de contacto</h3>

                <div class="grid grid-cols-1 sm:grid-cols-2 gap-6">
                  <div>
                    <.input
                      field={@form[:customer_name]}
                      type="text"
                      label="Nombre completo"
                      placeholder="Tu nombre completo"
                      value={@current_scope.user.name}
                      required
                    />
                  </div>

                  <div>
                    <.input
                      field={@form[:customer_phone]}
                      type="tel"
                      label="Teléfono"
                      placeholder="Tu número de teléfono"
                      value={@current_scope.user.phone_number}
                      required
                    />
                  </div>
                </div>

                <div class="mt-6">
                  <.input
                    field={@form[:customer_email]}
                    type="email"
                    label="Correo electrónico"
                    placeholder="tu@email.com"
                    value={@current_scope.user.email}
                    required
                  />
                </div>
              </div>
              
    <!-- Special Requests -->
              <div>
                <.input
                  field={@form[:special_requests]}
                  type="textarea"
                  label="Solicitudes especiales (opcional)"
                  placeholder="Alergias, preferencias de mesa, celebraciones especiales, etc."
                  rows="3"
                />
              </div>
              
    <!-- Working Hours Info -->
              <%= if not Enum.empty?(@working_hours) do %>
                <div class="bg-blue-50 border border-blue-200 rounded-lg p-4">
                  <h4 class="font-medium text-blue-900 mb-2">Horarios de atención</h4>
                  <div class="grid grid-cols-2 gap-2 text-sm text-blue-800">
                    <%= for working_hour <- @working_hours do %>
                      <div class="flex justify-between">
                        <span>
                          {FoodReserve.Restaurants.WorkingHour.day_name(working_hour.day_of_week)}
                        </span>
                        <span>
                          <%= if working_hour.is_closed do %>
                            Cerrado
                          <% else %>
                            {Calendar.strftime(working_hour.open_time, "%H:%M")} - {Calendar.strftime(
                              working_hour.close_time,
                              "%H:%M"
                            )}
                          <% end %>
                        </span>
                      </div>
                    <% end %>
                  </div>
                </div>
              <% end %>
              
    <!-- Submit Button -->
              <div class="flex justify-end gap-3 pt-6 border-t border-gray-200">
                <.link
                  navigate={~p"/restaurants/#{@restaurant}"}
                  class="inline-flex justify-center items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-lg text-gray-700 bg-white hover:bg-gray-50"
                >
                  Cancelar
                </.link>
                <.button
                  type="submit"
                  class="inline-flex justify-center items-center px-6 py-2 border border-transparent text-sm font-medium rounded-lg text-white bg-green-600 hover:bg-green-700"
                >
                  <.icon name="hero-check" class="w-4 h-4 mr-2" /> Confirmar Reserva
                </.button>
              </div>
            </.form>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"restaurant_id" => restaurant_id}, _session, socket) do
    restaurant = Restaurants.get_public_restaurant!(restaurant_id)
    working_hours = Restaurants.get_public_working_hours(restaurant.id)

    # Crear una nueva reserva con valores por defecto
    reservation = %Reservation{
      user_id: socket.assigns.current_scope.user.id,
      restaurant_id: restaurant.id,
      customer_name: socket.assigns.current_scope.user.name || "",
      customer_phone: socket.assigns.current_scope.user.phone_number || "",
      customer_email: socket.assigns.current_scope.user.email || ""
    }

    changeset = Reservations.change_reservation(socket.assigns.current_scope, reservation)

    {:ok,
     socket
     |> assign(:page_title, "Nueva Reserva")
     |> assign(:restaurant, restaurant)
     |> assign(:working_hours, working_hours)
     |> assign(:reservation, reservation)
     |> assign(:form, to_form(changeset))
     |> assign(:selected_date, nil)
     |> assign(:available_times, [])}
  end

  @impl true
  def handle_event(
        "date_changed",
        %{"reservation" => %{"reservation_date" => date_string}},
        socket
      ) do
    case Date.from_iso8601(date_string) do
      {:ok, date} ->
        available_times =
          get_available_times_for_date(
            date,
            socket.assigns.working_hours,
            socket.assigns.restaurant.id
          )

        {:noreply,
         socket
         |> assign(:selected_date, date)
         |> assign(:available_times, available_times)}

      {:error, _} ->
        {:noreply,
         socket
         |> assign(:selected_date, nil)
         |> assign(:available_times, [])}
    end
  end

  @impl true
  def handle_event("save", %{"reservation" => reservation_params}, socket) do
    # Agregar IDs necesarios
    reservation_params =
      reservation_params
      |> Map.put("user_id", socket.assigns.current_scope.user.id)
      |> Map.put("restaurant_id", socket.assigns.restaurant.id)

    case Reservations.create_reservation(socket.assigns.current_scope, reservation_params) do
      {:ok, _reservation} ->
        {:noreply,
         socket
         |> put_flash(
           :info,
           "¡Gracias por tu reserva! El restaurante se pondrá en comunicación contigo para confirmar los detalles de tu reserva."
         )
         |> push_navigate(to: ~p"/restaurants/#{socket.assigns.restaurant}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  defp get_available_times_for_date(date, working_hours, restaurant_id) do
    day_of_week = get_day_of_week_string(date)

    case Enum.find(working_hours, fn wh -> wh.day_of_week == day_of_week end) do
      nil ->
        []

      %{is_closed: true} ->
        []

      working_hour ->
        if working_hour.open_time && working_hour.close_time do
          # Generar todos los slots posibles
          all_slots = generate_time_slots(working_hour.open_time, working_hour.close_time)

          # Obtener horarios ya reservados para esta fecha
          reserved_times = Reservations.get_existing_reservations(restaurant_id, date)

          # Filtrar slots ya reservados
          available_slots =
            Enum.reject(all_slots, fn slot ->
              Enum.any?(reserved_times, fn reserved_time ->
                Time.compare(slot, reserved_time) == :eq
              end)
            end)

          available_slots
        else
          []
        end
    end
  end

  defp get_day_of_week_string(date) do
    case Date.day_of_week(date) do
      1 -> "monday"
      2 -> "tuesday"
      3 -> "wednesday"
      4 -> "thursday"
      5 -> "friday"
      6 -> "saturday"
      7 -> "sunday"
    end
  end

  defp generate_time_slots(open_time, close_time) do
    # Generar slots de 30 minutos desde la apertura hasta 1 hora antes del cierre
    # para dar tiempo a la comida
    start_time = open_time
    # 1 hora antes del cierre
    end_time = Time.add(close_time, -60, :minute)

    generate_slots(start_time, end_time, [])
  end

  defp generate_slots(current_time, end_time, acc) do
    if Time.compare(current_time, end_time) == :gt do
      Enum.reverse(acc)
    else
      # Slots de 30 minutos
      next_time = Time.add(current_time, 30, :minute)
      generate_slots(next_time, end_time, [current_time | acc])
    end
  end

  # Handle real-time notifications
  handle_notifications()
end
