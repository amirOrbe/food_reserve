defmodule FoodReserveWeb.WorkingHoursLive.Index do
  use FoodReserveWeb, :live_view

  alias FoodReserve.Restaurants
  alias FoodReserve.Restaurants.WorkingHour

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <!-- Header -->
        <div class="bg-white shadow-sm rounded-lg border border-gray-200 mb-6">
          <div class="px-6 py-8 sm:px-8">
            <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between">
              <div class="mb-4 sm:mb-0">
                <h1 class="text-3xl font-bold text-gray-900 mb-2">
                  Horarios de {@restaurant.name}
                </h1>
                <p class="text-gray-600">
                  Configura los días y horarios de atención de tu restaurante
                </p>
              </div>

              <div class="flex flex-col sm:flex-row gap-3">
                <.link
                  navigate={~p"/restaurants/#{@restaurant}"}
                  class="inline-flex justify-center items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-lg text-gray-700 bg-white hover:bg-gray-50"
                >
                  <.icon name="hero-arrow-left" class="w-4 h-4 mr-2" /> Volver al Restaurante
                </.link>
              </div>
            </div>
          </div>
        </div>
        
    <!-- Working Hours Form -->
        <div class="bg-white shadow-sm rounded-lg border border-gray-200">
          <div class="px-6 py-8 sm:px-8">
            <h2 class="text-lg font-medium text-gray-900 mb-6">Configurar Horarios</h2>

            <div class="space-y-6">
              <%= for day <- WorkingHour.days_of_week() do %>
                <% working_hour = get_working_hour_for_day(@working_hours, day) %>
                <div class="border border-gray-200 rounded-lg p-4">
                  <.form
                    for={%{}}
                    id={"working-hour-form-#{day}"}
                    phx-submit="save_working_hour"
                    class="space-y-4"
                  >
                    <input type="hidden" name="day_of_week" value={day} />

                    <div class="flex items-center justify-between">
                      <h3 class="text-base font-medium text-gray-900">
                        {WorkingHour.day_name(day)}
                      </h3>

                      <div class="flex items-center">
                        <input
                          type="checkbox"
                          name="is_closed"
                          id={"is_closed_#{day}"}
                          value="true"
                          checked={is_day_closed(working_hour)}
                          class="h-4 w-4 text-orange-600 focus:ring-orange-500 border-gray-300 rounded"
                          phx-click="toggle_closed"
                          phx-value-day={day}
                        />
                        <label for={"is_closed_#{day}"} class="ml-2 text-sm text-gray-600">
                          Cerrado
                        </label>
                      </div>
                    </div>

                    <%= if not is_day_closed(working_hour) do %>
                      <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                        <div>
                          <label class="block text-sm font-medium text-gray-700 mb-1">
                            Hora de apertura
                          </label>
                          <input
                            type="time"
                            name="open_time"
                            value={format_time_for_input(working_hour && working_hour.open_time)}
                            class="block w-full border-gray-300 rounded-md shadow-sm focus:ring-orange-500 focus:border-orange-500"
                            required={not is_day_closed(working_hour)}
                          />
                        </div>

                        <div>
                          <label class="block text-sm font-medium text-gray-700 mb-1">
                            Hora de cierre
                          </label>
                          <input
                            type="time"
                            name="close_time"
                            value={format_time_for_input(working_hour && working_hour.close_time)}
                            class="block w-full border-gray-300 rounded-md shadow-sm focus:ring-orange-500 focus:border-orange-500"
                            required={not is_day_closed(working_hour)}
                          />
                        </div>
                      </div>

                      <div class="flex justify-end">
                        <button
                          type="submit"
                          class="inline-flex items-center px-3 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-orange-600 hover:bg-orange-700"
                        >
                          Guardar
                        </button>
                      </div>
                    <% else %>
                      <div class="flex justify-end">
                        <button
                          type="submit"
                          class="inline-flex items-center px-3 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-orange-600 hover:bg-orange-700"
                        >
                          Guardar como cerrado
                        </button>
                      </div>
                    <% end %>
                  </.form>
                </div>
              <% end %>
            </div>
            
    <!-- Quick Actions -->
            <div class="mt-8 pt-6 border-t border-gray-200">
              <h3 class="text-base font-medium text-gray-900 mb-4">Acciones rápidas</h3>
              <div class="flex flex-wrap gap-3">
                <button
                  phx-click="set_standard_hours"
                  class="inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50"
                >
                  Horario estándar (9:00 - 18:00)
                </button>
                <button
                  phx-click="set_restaurant_hours"
                  class="inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50"
                >
                  Horario restaurante (12:00 - 22:00)
                </button>
                <button
                  phx-click="clear_all_hours"
                  data-confirm="¿Estás seguro de que quieres eliminar todos los horarios?"
                  class="inline-flex items-center px-4 py-2 border border-red-300 text-sm font-medium rounded-md text-red-700 bg-white hover:bg-red-50"
                >
                  Limpiar todo
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"restaurant_id" => restaurant_id}, _session, socket) do
    restaurant = Restaurants.get_restaurant!(socket.assigns.current_scope, restaurant_id)

    working_hours =
      Restaurants.list_working_hours_by_restaurant(socket.assigns.current_scope, restaurant.id)

    {:ok,
     socket
     |> assign(:page_title, "Gestionar Horarios")
     |> assign(:restaurant, restaurant)
     |> assign(:working_hours, working_hours)}
  end

  @impl true
  def handle_event("save_working_hour", params, socket) do
    case Restaurants.upsert_working_hour(
           socket.assigns.current_scope,
           socket.assigns.restaurant.id,
           params
         ) do
      {:ok, _working_hour} ->
        working_hours =
          Restaurants.list_working_hours_by_restaurant(
            socket.assigns.current_scope,
            socket.assigns.restaurant.id
          )

        {:noreply,
         socket
         |> put_flash(:info, "Horario guardado exitosamente")
         |> assign(:working_hours, working_hours)}

      {:error, changeset} ->
        errors =
          changeset.errors
          |> Enum.map(fn {field, {message, _}} -> "#{field}: #{message}" end)
          |> Enum.join(", ")

        {:noreply,
         socket
         |> put_flash(:error, "Error al guardar: #{errors}")}
    end
  end

  @impl true
  def handle_event("toggle_closed", %{"day" => day}, socket) do
    working_hour = get_working_hour_for_day(socket.assigns.working_hours, day)
    is_closed = if working_hour, do: not working_hour.is_closed, else: true

    params = %{
      "day_of_week" => day,
      "is_closed" => is_closed
    }

    case Restaurants.upsert_working_hour(
           socket.assigns.current_scope,
           socket.assigns.restaurant.id,
           params
         ) do
      {:ok, _working_hour} ->
        working_hours =
          Restaurants.list_working_hours_by_restaurant(
            socket.assigns.current_scope,
            socket.assigns.restaurant.id
          )

        {:noreply, assign(socket, :working_hours, working_hours)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Error al actualizar el estado")}
    end
  end

  @impl true
  def handle_event("set_standard_hours", _params, socket) do
    set_bulk_hours(socket, "09:00", "18:00")
  end

  @impl true
  def handle_event("set_restaurant_hours", _params, socket) do
    set_bulk_hours(socket, "12:00", "22:00")
  end

  @impl true
  def handle_event("clear_all_hours", _params, socket) do
    # Eliminar todos los horarios existentes
    Enum.each(socket.assigns.working_hours, fn working_hour ->
      Restaurants.delete_working_hour(socket.assigns.current_scope, working_hour)
    end)

    {:noreply,
     socket
     |> put_flash(:info, "Todos los horarios han sido eliminados")
     |> assign(:working_hours, [])}
  end

  defp set_bulk_hours(socket, open_time, close_time) do
    weekdays = ["monday", "tuesday", "wednesday", "thursday", "friday"]

    results =
      Enum.map(weekdays, fn day ->
        params = %{
          "day_of_week" => day,
          "open_time" => open_time,
          "close_time" => close_time,
          "is_closed" => false
        }

        Restaurants.upsert_working_hour(
          socket.assigns.current_scope,
          socket.assigns.restaurant.id,
          params
        )
      end)

    if Enum.all?(results, fn {status, _} -> status == :ok end) do
      working_hours =
        Restaurants.list_working_hours_by_restaurant(
          socket.assigns.current_scope,
          socket.assigns.restaurant.id
        )

      {:noreply,
       socket
       |> put_flash(:info, "Horarios configurados exitosamente")
       |> assign(:working_hours, working_hours)}
    else
      {:noreply, put_flash(socket, :error, "Error al configurar los horarios")}
    end
  end

  defp get_working_hour_for_day(working_hours, day) do
    Enum.find(working_hours, fn wh -> wh.day_of_week == day end)
  end

  defp format_time_for_input(nil), do: ""

  defp format_time_for_input(time) when is_struct(time, Time) do
    Time.to_string(time)
  end

  defp format_time_for_input(_), do: ""

  defp is_day_closed(nil), do: false
  defp is_day_closed(working_hour), do: working_hour.is_closed || false
end
