defmodule FoodReserveWeb.ReservationLive.New do
  use FoodReserveWeb, :live_view
  import FoodReserveWeb.LiveHelpers

  alias FoodReserve.Restaurants
  alias FoodReserve.Menus
  alias FoodReserve.Orders
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
              
    <!-- Pre-order Option -->
              <div class="mt-6 border-t border-gray-200 pt-6">
                <h3 class="text-lg font-medium text-gray-900 mb-4">Pre-orden de alimentos</h3>
                <div class="flex items-center">
                  <input
                    type="checkbox"
                    id="pre_order"
                    name="pre_order"
                    phx-click="toggle_pre_order"
                    checked={@show_pre_order}
                    class="h-4 w-4 text-orange-600 border-gray-300 rounded focus:ring-orange-500"
                  />
                  <label for="pre_order" class="ml-2 block text-gray-700">
                    Pre-ordenar platillos para tener tu comida lista al llegar
                  </label>
                </div>
              </div>
              
    <!-- Menu Items Selection -->
              <%= if @show_pre_order do %>
                <div class="mt-4 bg-gray-50 p-4 rounded-lg border border-gray-200">
                  <%= if Enum.empty?(@menu_items) do %>
                    <p class="text-gray-500 italic">
                      Este restaurante no tiene platillos disponibles para ordenar.
                    </p>
                  <% else %>
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                      <%= for {category, items} <- group_by_category(@menu_items) do %>
                        <div class="bg-white p-4 rounded shadow-sm">
                          <h3 class="font-semibold text-gray-800 mb-2">
                            {String.capitalize(category)}
                          </h3>
                          <div class="space-y-3">
                            <%= for item <- items do %>
                              <div class="flex items-center justify-between border-b pb-2">
                                <div>
                                  <div class="font-medium">{item.name}</div>
                                  <div class="text-sm text-gray-500">{item.description}</div>
                                  <div class="text-sm font-semibold mt-1">
                                    ${format_price(item.price)}
                                  </div>
                                </div>
                                <div class="flex items-center">
                                  <button
                                    type="button"
                                    phx-click="decrement"
                                    phx-value-id={item.id}
                                    class="bg-gray-200 hover:bg-gray-300 text-gray-700 font-bold py-1 px-2 rounded-l"
                                  >
                                    -
                                  </button>
                                  <span class="bg-white px-3 py-1 border-t border-b">
                                    {get_item_quantity(assigns, item.id)}
                                  </span>
                                  <button
                                    type="button"
                                    phx-click="increment"
                                    phx-value-id={item.id}
                                    class="bg-gray-200 hover:bg-gray-300 text-gray-700 font-bold py-1 px-2 rounded-r"
                                  >
                                    +
                                  </button>
                                </div>
                              </div>
                            <% end %>
                          </div>
                        </div>
                      <% end %>
                    </div>
                    
    <!-- Order Total -->
                    <div class="mt-4 border-t border-gray-200 pt-4 flex justify-between items-center">
                      <div class="text-lg font-semibold">
                        Total: ${format_price(calculate_total(assigns))}
                      </div>
                      <div class="text-sm text-gray-500">
                        {selected_items_count(assigns)} platillos seleccionados
                      </div>
                    </div>
                    
    <!-- Order Instructions -->
                    <div class="mt-4">
                      <.input
                        field={@form[:order_instructions]}
                        type="textarea"
                        label="Instrucciones del pedido (opcional)"
                        placeholder="Instrucciones especiales para la preparación de los alimentos, alergias, etc."
                        rows="2"
                      />
                    </div>
                  <% end %>
                </div>
              <% end %>
              
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

    # Generar fechas disponibles (próximos 30 días)
    today = Date.utc_today()
    available_dates = Date.range(today, Date.add(today, 30))

    # Crear una nueva reserva con valores por defecto
    reservation = %Reservation{
      user_id: socket.assigns.current_scope.user.id,
      restaurant_id: restaurant.id,
      customer_name: socket.assigns.current_scope.user.name || "",
      customer_phone: socket.assigns.current_scope.user.phone_number || "",
      customer_email: socket.assigns.current_scope.user.email || ""
    }

    changeset = Reservations.change_reservation(socket.assigns.current_scope, reservation)

    # Cargar menú del restaurante para pre-ordenar
    menu_items = Menus.list_menu_items_for_restaurant(restaurant.id, true)

    # Inicializar un mapa de cantidades vacío
    quantities = menu_items |> Enum.map(&{&1.id, 0}) |> Map.new()

    {:ok,
     socket
     |> assign(:page_title, "Reserva")
     |> assign(:restaurant, restaurant)
     |> assign(:working_hours, working_hours)
     |> assign(:available_dates, available_dates)
     |> assign(:selected_date, nil)
     |> assign(:available_times, [])
     |> assign(:selected_time, nil)
     |> assign(:form, to_form(changeset))
     # Asignaciones para pre-orden
     |> assign(:show_pre_order, false)
     |> assign(:menu_items, menu_items)
     |> assign(:quantities, quantities)}
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

    # Crear la reservación primero
    case Reservations.create_reservation(socket.assigns.current_scope, reservation_params) do
      {:ok, reservation} ->
        # Si se activó pre-orden y hay items seleccionados, crear pedido
        if socket.assigns.show_pre_order && has_selected_items?(socket.assigns) do
          # Crear los ítems del pedido
          order_items = create_order_items(socket.assigns)

          # Calcular el total de la orden primero
          total = calculate_total(socket.assigns)

          # Crear la orden (usando solo string keys)
          order_attrs = %{
            "reservation_id" => reservation.id,
            "special_instructions" => reservation_params["order_instructions"] || "",
            "status" => "pending",
            "total_amount" => total
          }

          case Orders.create_order(order_attrs, order_items) do
            {:ok, _order} ->
              {:noreply,
               socket
               |> put_flash(
                 :info,
                 "¡Gracias por tu reserva y pedido! Te notificaremos cuando tu pedido sea confirmado."
               )
               |> push_navigate(to: ~p"/restaurants/#{socket.assigns.restaurant}")}

            {:error, _} ->
              # Si falla la creación del pedido, igual mostramos éxito en la reserva
              {:noreply,
               socket
               |> put_flash(
                 :info,
                 "¡Gracias por tu reserva! El restaurante se pondrá en comunicación contigo para confirmar los detalles."
               )
               |> push_navigate(to: ~p"/restaurants/#{socket.assigns.restaurant}")}
          end
        else
          # Sin pre-orden, solo confirmamos la reserva
          {:noreply,
           socket
           |> put_flash(
             :info,
             "¡Gracias por tu reserva! El restaurante se pondrá en comunicación contigo para confirmar los detalles."
           )
           |> push_navigate(to: ~p"/restaurants/#{socket.assigns.restaurant}")}
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  @impl true
  def handle_event("toggle_pre_order", _params, socket) do
    {:noreply, assign(socket, :show_pre_order, !socket.assigns.show_pre_order)}
  end

  @impl true
  def handle_event("increment", %{"id" => id}, socket) do
    item_id = String.to_integer(id)
    quantities = Map.update(socket.assigns.quantities, item_id, 1, &(&1 + 1))

    {:noreply, assign(socket, :quantities, quantities)}
  end

  @impl true
  def handle_event("decrement", %{"id" => id}, socket) do
    item_id = String.to_integer(id)
    current_qty = Map.get(socket.assigns.quantities, item_id, 0)

    if current_qty > 0 do
      quantities = Map.update(socket.assigns.quantities, item_id, 0, &max(0, &1 - 1))
      {:noreply, assign(socket, :quantities, quantities)}
    else
      {:noreply, socket}
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

  # Función auxiliar para agrupar elementos del menú por categoría
  defp group_by_category(menu_items) do
    menu_items
    |> Enum.group_by(fn item -> item.category end)
  end

  # Función auxiliar para obtener la cantidad de un elemento
  defp get_item_quantity(assigns, item_id) do
    Map.get(assigns.quantities, item_id, 0)
  end

  # Función auxiliar para calcular el total
  defp calculate_total(assigns) do
    Enum.reduce(assigns.quantities, Decimal.new(0), fn {item_id, qty}, acc ->
      if qty > 0 do
        item = Enum.find(assigns.menu_items, &(&1.id == item_id))
        item_total = Decimal.mult(item.price, Decimal.new(qty))
        Decimal.add(acc, item_total)
      else
        acc
      end
    end)
  end

  # Función auxiliar para contar elementos seleccionados
  defp selected_items_count(assigns) do
    Enum.count(assigns.quantities, fn {_, qty} -> qty > 0 end)
  end

  # Función auxiliar para verificar si hay elementos seleccionados
  defp has_selected_items?(assigns) do
    selected_items_count(assigns) > 0
  end

  # Función auxiliar para crear los elementos del pedido
  defp create_order_items(assigns) do
    menu_items_map =
      Enum.reduce(assigns.menu_items, %{}, fn item, acc -> Map.put(acc, item.id, item) end)

    assigns.quantities
    |> Enum.filter(fn {_, qty} -> qty > 0 end)
    |> Enum.map(fn {item_id, qty} ->
      menu_item = menu_items_map[item_id]

      %{
        menu_item_id: item_id,
        quantity: qty,
        price: menu_item.price,
        notes: ""
      }
    end)
  end

  # Función auxiliar para formatear precios
  defp format_price(price) do
    :erlang.float_to_binary(Decimal.to_float(price), decimals: 2)
  end

  # Handle real-time notifications
  handle_notifications()
end
