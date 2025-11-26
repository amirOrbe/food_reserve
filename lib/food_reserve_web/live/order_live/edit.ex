defmodule FoodReserveWeb.OrderLive.Edit do
  use FoodReserveWeb, :live_view
  alias FoodReserve.Orders
  alias FoodReserve.Restaurants

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    current_scope = socket.assigns.current_scope

    case Orders.get_order(id) do
      nil ->
        {:ok,
         socket
         |> put_flash(:error, "Pedido no encontrado")
         |> push_navigate(to: ~p"/my-orders")}

      order ->
        # Verificar que el usuario es dueño del pedido y que el pedido es de tipo "pickup"
        if order.user_id != current_scope.user.id || order.order_type != "pickup" do
          {:ok,
           socket
           |> put_flash(:error, "No tienes permiso para editar este pedido")
           |> push_navigate(to: ~p"/my-orders")}
        else
          # Verificar que el pedido es editable (status = pending)
          if order.status != "pending" do
            {:ok,
             socket
             |> put_flash(
               :error,
               "Este pedido ya no se puede editar porque su estado es #{order_status_text(order.status)}"
             )
             |> push_navigate(to: ~p"/orders/#{order.id}")}
          else
            # Obtener horarios disponibles del restaurante
            restaurant = order.restaurant
            today = local_today()
            working_hours = get_working_hours(restaurant.id, today)
            available_hours = get_available_hours(working_hours)

            # Crear el form para editar
            changeset = Orders.change_order(order)

            {:ok,
             socket
             |> assign(:page_title, "Editar Pedido ##{order.id}")
             |> assign(:order, order)
             |> assign(:restaurant, restaurant)
             |> assign(:available_hours, available_hours)
             |> assign(:form, to_form(changeset))}
          end
        end
    end
  end

  @impl true
  def handle_event("save", %{"order" => order_params}, socket) do
    order = socket.assigns.order

    case Orders.update_pickup_order(order, order_params) do
      {:ok, updated_order} ->
        {:noreply,
         socket
         |> put_flash(:info, "Pedido actualizado correctamente")
         |> push_navigate(to: ~p"/orders/#{updated_order.id}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}

      {:error, :not_editable} ->
        {:noreply,
         socket
         |> put_flash(:error, "Este pedido ya no se puede editar")
         |> push_navigate(to: ~p"/orders/#{order.id}")}
    end
  end

  @impl true
  def handle_event("validate", %{"order" => order_params}, socket) do
    changeset =
      socket.assigns.order
      |> Orders.change_order(order_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app
      flash={@flash}
      current_scope={@current_scope}
      unread_notifications_count={@unread_notifications_count}
    >
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div class="max-w-3xl mx-auto">
          <div class="flex items-center justify-between mb-8">
            <div>
              <h1 class="text-2xl font-bold text-gray-900">Editar Pedido #{@order.id}</h1>
              <p class="mt-1 text-sm text-gray-500">
                {@restaurant.name}
              </p>
            </div>
            <div>
              <.link
                navigate={~p"/orders/#{@order.id}"}
                class="text-sm font-medium text-blue-600 hover:text-blue-500"
              >
                ← Volver a detalles del pedido
              </.link>
            </div>
          </div>

          <div class="bg-white shadow overflow-hidden sm:rounded-lg">
            <div class="px-4 py-5 sm:p-6">
              <.form for={@form} phx-submit="save" phx-change="validate" class="space-y-6">
                <div>
                  <label for="pickup_date" class="block text-sm font-medium text-gray-700">
                    Fecha de recogida
                  </label>
                  <div class="mt-1">
                    <.input
                      field={@form[:pickup_date]}
                      type="date"
                      readonly
                      class="block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
                    />
                    <p class="mt-1 text-xs text-gray-500">
                      La fecha no se puede modificar para pedidos ya realizados.
                    </p>
                  </div>
                </div>

                <div>
                  <label class="block text-sm font-medium text-gray-700">
                    Hora de recogida
                  </label>
                  <div class="mt-1">
                    <select
                      name="order[pickup_time]"
                      class="block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
                      required
                    >
                      <%= for time <- @available_hours do %>
                        <option
                          value={"#{time.hour}:#{String.pad_leading("#{time.minute}", 2, "0")}"}
                          selected={time_equals(@order.pickup_time, time)}
                        >
                          {time_to_string(time)}
                        </option>
                      <% end %>
                    </select>
                  </div>
                </div>

                <div>
                  <.input
                    field={@form[:pickup_name]}
                    type="text"
                    label="Nombre para recoger el pedido"
                    placeholder="Nombre completo"
                    required
                    class="block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
                  />
                </div>

                <div>
                  <.input
                    field={@form[:pickup_phone]}
                    type="tel"
                    label="Teléfono de contacto"
                    placeholder="10 dígitos"
                    required
                    class="block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
                  />
                </div>

                <div>
                  <.input
                    field={@form[:special_instructions]}
                    type="textarea"
                    label="Instrucciones especiales"
                    placeholder="Indicaciones adicionales para tu pedido"
                    rows="3"
                    class="block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
                  />
                </div>

                <div class="flex items-center justify-end space-x-3">
                  <.link
                    navigate={~p"/orders/#{@order.id}"}
                    class="inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md shadow-sm text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
                  >
                    Cancelar
                  </.link>
                  <button
                    type="submit"
                    class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
                  >
                    Guardar cambios
                  </button>
                </div>
              </.form>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  # Funciones auxiliares

  defp local_today do
    utc_datetime = DateTime.utc_now()
    # Restamos 6 horas para GMT-6
    local_datetime = DateTime.add(utc_datetime, -6 * 60 * 60, :second)
    DateTime.to_date(local_datetime)
  end

  defp local_time do
    utc_datetime = DateTime.utc_now()
    # Restamos 6 horas para GMT-6
    local_datetime = DateTime.add(utc_datetime, -6 * 60 * 60, :second)
    DateTime.to_time(local_datetime)
  end

  defp get_working_hours(restaurant_id, date) do
    # Obtener el horario del restaurante para ese día
    Restaurants.get_working_hours_for_date(restaurant_id, date)
  end

  defp get_available_hours(working_hours) do
    if working_hours && !working_hours.is_closed do
      # Establecer intervalo de 30 minutos
      interval_minutes = 30

      # Obtener hora actual
      now = local_time()

      # Generar lista de horas disponibles
      open_time = working_hours.open_time
      close_time = working_hours.close_time

      # Ajustar hora inicial para que sea el próximo intervalo de 30 minutos
      initial_hour = open_time.hour
      initial_minute = open_time.minute
      adjusted_minute = round(Float.ceil(initial_minute / interval_minutes) * interval_minutes)

      adjusted_hour =
        if adjusted_minute >= 60 do
          initial_hour + 1
        else
          initial_hour
        end

      adjusted_minute =
        if adjusted_minute >= 60 do
          0
        else
          adjusted_minute
        end

      initial_time = Time.new!(adjusted_hour, adjusted_minute, 0)

      # Si la hora actual ya pasó la hora de apertura, comenzar desde la siguiente hora disponible
      initial_time =
        if Time.compare(now, initial_time) == :gt do
          now_minute = now.minute
          adjusted_minute = round(Float.ceil(now_minute / interval_minutes) * interval_minutes)

          adjusted_hour =
            if adjusted_minute >= 60 do
              now.hour + 1
            else
              now.hour
            end

          adjusted_minute =
            if adjusted_minute >= 60 do
              adjusted_minute - 60
            else
              adjusted_minute
            end

          # Si ya es muy tarde, mostrar desde mañana
          if Time.compare(Time.new!(adjusted_hour, adjusted_minute, 0), close_time) != :lt do
            initial_time
          else
            Time.new!(adjusted_hour, adjusted_minute, 0)
          end
        else
          initial_time
        end

      # Generar horas hasta cierre
      generate_time_slots(initial_time, close_time, interval_minutes, [])
    else
      []
    end
  end

  defp generate_time_slots(current_time, close_time, interval, acc) do
    if Time.compare(current_time, close_time) == :lt do
      next_time = add_minutes(current_time, interval)
      generate_time_slots(next_time, close_time, interval, [current_time | acc])
    else
      Enum.reverse(acc)
    end
  end

  defp add_minutes(%Time{} = time, minutes) do
    seconds = time.hour * 3600 + time.minute * 60 + time.second
    new_seconds = seconds + minutes * 60

    new_hour = div(new_seconds, 3600) |> rem(24)
    new_minute = div(rem(new_seconds, 3600), 60)
    new_second = rem(new_seconds, 60)

    Time.new!(new_hour, new_minute, new_second)
  end

  defp time_to_string(%Time{} = time) do
    "#{time.hour}:#{String.pad_leading("#{time.minute}", 2, "0")}"
  end

  defp time_equals(%Time{} = time1, %Time{} = time2) do
    time1.hour == time2.hour && time1.minute == time2.minute
  end

  defp order_status_text(status) do
    case status do
      "pending" -> "pendiente"
      "confirmed" -> "confirmado"
      "rejected" -> "rechazado"
      "completed" -> "completado"
      _ -> status
    end
  end
end
