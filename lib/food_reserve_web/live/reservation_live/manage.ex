defmodule FoodReserveWeb.ReservationLive.Manage do
  use FoodReserveWeb, :live_view

  alias FoodReserve.Restaurants
  alias FoodReserve.Reservations

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <!-- Header -->
        <div class="bg-white shadow-sm rounded-lg border border-gray-200 mb-6">
          <div class="px-6 py-8 sm:px-8">
            <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between">
              <div class="mb-4 sm:mb-0">
                <h1 class="text-3xl font-bold text-gray-900 mb-2">
                  Gestión de Reservas
                </h1>
                <p class="text-gray-600">
                  Restaurante: <span class="font-medium">{@restaurant.name}</span>
                </p>
              </div>

              <div class="flex flex-col sm:flex-row gap-3">
                <.link
                  navigate={~p"/restaurants/#{@restaurant}"}
                  class="inline-flex justify-center items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-lg text-gray-700 bg-white hover:bg-gray-50"
                >
                  <.icon name="hero-arrow-left" class="w-4 h-4 mr-2" /> Volver al Restaurante
                </.link>

                <.link
                  navigate={~p"/restaurants"}
                  class="inline-flex justify-center items-center px-4 py-2 border border-transparent text-sm font-medium rounded-lg text-white bg-orange-600 hover:bg-orange-700"
                >
                  <.icon name="hero-building-storefront" class="w-4 h-4 mr-2" /> Mis Restaurantes
                </.link>
              </div>
            </div>
          </div>
        </div>
        
    <!-- Filters -->
        <div class="bg-white shadow-sm rounded-lg border border-gray-200 mb-6">
          <div class="px-6 py-4">
            <div class="flex flex-wrap gap-4">
              <button
                phx-click="filter_status"
                phx-value-status="pending"
                class={[
                  "px-4 py-2 text-sm font-medium rounded-lg transition-colors",
                  if(@filter_status == "pending",
                    do: "bg-yellow-100 text-yellow-800 border border-yellow-200",
                    else: "bg-gray-100 text-gray-700 hover:bg-gray-200"
                  )
                ]}
              >
                Pendientes ({@pending_count})
              </button>

              <button
                phx-click="filter_status"
                phx-value-status="all"
                class={[
                  "px-4 py-2 text-sm font-medium rounded-lg transition-colors",
                  if(@filter_status == "all",
                    do: "bg-orange-100 text-orange-800 border border-orange-200",
                    else: "bg-gray-100 text-gray-700 hover:bg-gray-200"
                  )
                ]}
              >
                Todas ({@total_count})
              </button>

              <button
                phx-click="filter_status"
                phx-value-status="confirmed"
                class={[
                  "px-4 py-2 text-sm font-medium rounded-lg transition-colors",
                  if(@filter_status == "confirmed",
                    do: "bg-green-100 text-green-800 border border-green-200",
                    else: "bg-gray-100 text-gray-700 hover:bg-gray-200"
                  )
                ]}
              >
                Confirmadas ({@confirmed_count})
              </button>
            </div>
          </div>
        </div>
        
    <!-- Reservations List -->
        <%= if Enum.empty?(@filtered_reservations) do %>
          <div class="text-center py-12 bg-white rounded-lg shadow-sm">
            <div class="mx-auto w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mb-4">
              <.icon name="hero-calendar-days" class="w-8 h-8 text-gray-400" />
            </div>
            <h3 class="text-lg font-medium text-gray-900 mb-2">
              <%= case @filter_status do %>
                <% "pending" -> %>
                  No hay reservas pendientes
                <% "confirmed" -> %>
                  No hay reservas confirmadas
                <% _ -> %>
                  No hay reservas aún
              <% end %>
            </h3>
            <p class="text-gray-500">
              <%= if @filter_status == "pending" do %>
                Las nuevas reservas aparecerán aquí para tu revisión
              <% else %>
                Cuando los clientes hagan reservas, aparecerán aquí
              <% end %>
            </p>
          </div>
        <% else %>
          <div class="bg-white shadow-sm rounded-lg overflow-hidden">
            <div class="overflow-x-auto">
              <table class="min-w-full divide-y divide-gray-200">
                <thead class="bg-gray-50">
                  <tr>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Cliente
                    </th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Fecha y Hora
                    </th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Personas
                    </th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Estado
                    </th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Acciones
                    </th>
                  </tr>
                </thead>
                <tbody class="bg-white divide-y divide-gray-200">
                  <%= for reservation <- @filtered_reservations do %>
                    <% IO.inspect(reservation, label: "RESERVATION STRUCTURE") %>
                    <tr class="hover:bg-gray-50">
                      <td class="px-6 py-4 whitespace-nowrap">
                        <div>
                          <div class="text-sm font-medium text-gray-900">
                            {reservation.customer_name}
                          </div>
                          <div class="text-sm text-gray-500">
                            {reservation.customer_phone}
                          </div>
                        </div>
                      </td>
                      <td class="px-6 py-4 whitespace-nowrap">
                        <div class="text-sm text-gray-900">
                          {Calendar.strftime(reservation.reservation_date, "%d/%m/%Y")}
                        </div>
                        <div class="text-sm text-gray-500">
                          {Calendar.strftime(reservation.reservation_time, "%H:%M")}
                        </div>
                      </td>
                      <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {reservation.party_size}
                      </td>
                      <td class="px-6 py-4 whitespace-nowrap">
                        <span class={[
                          "inline-flex items-center px-2 py-1 rounded-full text-xs font-medium",
                          case reservation.status do
                            "pending" -> "bg-yellow-100 text-yellow-800"
                            "confirmed" -> "bg-green-100 text-green-800"
                            "cancelled" -> "bg-red-100 text-red-800"
                            _ -> "bg-gray-100 text-gray-800"
                          end
                        ]}>
                          <%= case reservation.status do %>
                            <% "pending" -> %>
                              Pendiente
                            <% "confirmed" -> %>
                              Confirmada
                            <% "cancelled" -> %>
                              Cancelada
                            <% _ -> %>
                              Desconocido
                          <% end %>
                        </span>
                      </td>
                      <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                        <%= if reservation.status == "pending" do %>
                          <!-- DEBUG: ID = <%= Map.get(reservation, :id) %> -->
                          <div class="flex gap-2">
                            <button
                              phx-click="confirm_reservation"
                              phx-value-id={Map.get(reservation, :id)}
                              type="button"
                              class="inline-flex items-center px-3 py-1 border border-transparent text-xs font-medium rounded text-white bg-green-600 hover:bg-green-700"
                            >
                              Aceptar (ID: {Map.get(reservation, :id)})
                            </button>
                            <button
                              phx-click="decline_reservation"
                              phx-value-id={Map.get(reservation, :id)}
                              type="button"
                              data-confirm="¿Estás seguro de que quieres declinar esta reserva?"
                              class="inline-flex items-center px-3 py-1 border border-transparent text-xs font-medium rounded text-white bg-red-600 hover:bg-red-700"
                            >
                              Declinar
                            </button>
                          </div>
                        <% else %>
                          <span class="text-gray-400">
                            <%= case reservation.status do %>
                              <% "confirmed" -> %>
                                Ya confirmada
                              <% "cancelled" -> %>
                                Declinada
                              <% _ -> %>
                                -
                            <% end %>
                          </span>
                        <% end %>
                      </td>
                    </tr>
                  <% end %>
                </tbody>
              </table>
            </div>
          </div>
        <% end %>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"restaurant_id" => restaurant_id}, _session, socket) do
    restaurant = Restaurants.get_restaurant!(socket.assigns.current_scope, restaurant_id)

    reservations =
      Reservations.list_restaurant_reservations(socket.assigns.current_scope, restaurant_id)

    # Calcular contadores por estado
    total_count = length(reservations)
    pending_count = Enum.count(reservations, &(&1.status == "pending"))
    confirmed_count = Enum.count(reservations, &(&1.status == "confirmed"))

    {:ok,
     socket
     |> assign(:page_title, "Gestión de Reservas - #{restaurant.name}")
     |> assign(:restaurant, restaurant)
     |> assign(:reservations, reservations)
     |> assign(:filtered_reservations, Enum.filter(reservations, &(&1.status == "pending")))
     |> assign(:filter_status, "pending")
     |> assign(:total_count, total_count)
     |> assign(:pending_count, pending_count)
     |> assign(:confirmed_count, confirmed_count)}
  end

  @impl true
  def handle_event("filter_status", %{"status" => status}, socket) do
    filtered_reservations =
      case status do
        "all" -> socket.assigns.reservations
        status -> Enum.filter(socket.assigns.reservations, &(&1.status == status))
      end

    {:noreply,
     socket
     |> assign(:filter_status, status)
     |> assign(:filtered_reservations, filtered_reservations)}
  end

  @impl true
  def handle_event("confirm_reservation", params, socket) do
    IO.puts("=== CONFIRM RESERVATION EVENT RECEIVED ===")
    IO.inspect(params, label: "PARAMS")

    # Extraer ID de los parámetros (puede venir como "id" o "value")
    id = params["id"] || params["value"] || ""
    IO.puts("ID: #{id}")
    IO.inspect(socket.assigns.current_scope.user, label: "USER")

    if id == "" or is_nil(id) do
      {:noreply, put_flash(socket, :error, "ID de reserva no válido")}
    else
      case Reservations.confirm_reservation(socket.assigns.current_scope, String.to_integer(id)) do
        {:ok, :updated} ->
          # Recargar reservas
          reservations =
            Reservations.list_restaurant_reservations(
              socket.assigns.current_scope,
              socket.assigns.restaurant.id
            )

          # Recalcular contadores
          pending_count = Enum.count(reservations, &(&1.status == "pending"))
          confirmed_count = Enum.count(reservations, &(&1.status == "confirmed"))

          # Aplicar filtro actual
          filtered_reservations =
            case socket.assigns.filter_status do
              "all" -> reservations
              status -> Enum.filter(reservations, &(&1.status == status))
            end

          {:noreply,
           socket
           |> put_flash(:info, "Reserva confirmada exitosamente")
           |> assign(:reservations, reservations)
           |> assign(:filtered_reservations, filtered_reservations)
           |> assign(:pending_count, pending_count)
           |> assign(:confirmed_count, confirmed_count)}

        {:error, :not_found} ->
          {:noreply,
           put_flash(socket, :error, "No se pudo confirmar la reserva - reserva no encontrada")}

        {:error, _} ->
          {:noreply, put_flash(socket, :error, "No se pudo confirmar la reserva")}
      end
    end
  end

  @impl true
  def handle_event("decline_reservation", params, socket) do
    IO.puts("=== DECLINE RESERVATION EVENT RECEIVED ===")
    IO.inspect(params, label: "PARAMS")

    # Extraer ID de los parámetros (puede venir como "id" o "value")
    id = params["id"] || params["value"] || ""
    IO.puts("ID: #{id}")

    if id == "" or is_nil(id) do
      {:noreply, put_flash(socket, :error, "ID de reserva no válido")}
    else
      case Reservations.decline_reservation(socket.assigns.current_scope, String.to_integer(id)) do
        {:ok, :updated} ->
          # Recargar reservas
          reservations =
            Reservations.list_restaurant_reservations(
              socket.assigns.current_scope,
              socket.assigns.restaurant.id
            )

          # Recalcular contadores
          pending_count = Enum.count(reservations, &(&1.status == "pending"))
          confirmed_count = Enum.count(reservations, &(&1.status == "confirmed"))

          # Aplicar filtro actual
          filtered_reservations =
            case socket.assigns.filter_status do
              "all" -> reservations
              status -> Enum.filter(reservations, &(&1.status == status))
            end

          {:noreply,
           socket
           |> put_flash(:info, "Reserva declinada")
           |> assign(:reservations, reservations)
           |> assign(:filtered_reservations, filtered_reservations)
           |> assign(:pending_count, pending_count)
           |> assign(:confirmed_count, confirmed_count)}

        {:error, :not_found} ->
          {:noreply,
           put_flash(socket, :error, "No se pudo declinar la reserva - reserva no encontrada")}

        {:error, _} ->
          {:noreply, put_flash(socket, :error, "No se pudo declinar la reserva")}
      end
    end
  end

  @impl true
  def handle_event(event_name, params, socket) do
    IO.puts("=== UNHANDLED EVENT ===")
    IO.puts("Event: #{event_name}")
    IO.inspect(params, label: "PARAMS")
    {:noreply, socket}
  end
end
