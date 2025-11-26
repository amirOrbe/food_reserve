defmodule FoodReserveWeb.ReservationLive.Index do
  use FoodReserveWeb, :live_view
  import FoodReserveWeb.LiveHelpers

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
      <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <!-- Header -->
        <div class="bg-white shadow-sm rounded-lg border border-gray-200 mb-6">
          <div class="px-6 py-8 sm:px-8">
            <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between">
              <div class="mb-4 sm:mb-0">
                <h1 class="text-3xl font-bold text-gray-900 mb-2">
                  Mis Reservas
                </h1>
                <p class="text-gray-600">Historial completo de todas tus reservas</p>
              </div>

              <div class="flex flex-col sm:flex-row gap-3">
                <.link
                  navigate={~p"/restaurants"}
                  class="inline-flex justify-center items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-lg text-gray-700 bg-white hover:bg-gray-50"
                >
                  <.icon name="hero-arrow-left" class="w-4 h-4 mr-2" /> Volver a Restaurantes
                </.link>

                <.link
                  navigate={~p"/"}
                  class="inline-flex justify-center items-center px-4 py-2 border border-transparent text-sm font-medium rounded-lg text-white bg-orange-600 hover:bg-orange-700"
                >
                  <.icon name="hero-magnifying-glass" class="w-4 h-4 mr-2" /> Explorar Restaurantes
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
                <% "all" -> %>
                  No tienes reservas aún
                <% "pending" -> %>
                  No tienes reservas pendientes
                <% "confirmed" -> %>
                  No tienes reservas confirmadas
                <% _ -> %>
                  No hay reservas con este filtro
              <% end %>
            </h3>
            <p class="text-gray-500 mb-6">
              <%= if @filter_status == "all" do %>
                Explora restaurantes y haz tu primera reserva
              <% else %>
                Cambia el filtro para ver otras reservas
              <% end %>
            </p>
            <%= if @filter_status == "all" do %>
              <.link
                navigate={~p"/"}
                class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-lg text-white bg-orange-600 hover:bg-orange-700"
              >
                <.icon name="hero-magnifying-glass" class="w-4 h-4 mr-2" /> Explorar Restaurantes
              </.link>
            <% end %>
          </div>
        <% else %>
          <div class="space-y-4">
            <%= for reservation <- @filtered_reservations do %>
              <div class="bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden">
                <div class="p-6">
                  <div class="flex flex-col lg:flex-row lg:items-center lg:justify-between">
                    <!-- Restaurant Info -->
                    <div class="flex-1 mb-4 lg:mb-0">
                      <div class="flex items-start justify-between mb-3">
                        <div>
                          <h3 class="text-lg font-semibold text-gray-900 mb-1">
                            {reservation.restaurant.name}
                          </h3>
                          <p class="text-sm text-gray-600">
                            {reservation.restaurant.address}
                          </p>
                        </div>

                        <span class={[
                          "inline-flex items-center px-3 py-1 rounded-full text-sm font-medium",
                          case reservation.status do
                            "pending" -> "bg-yellow-100 text-yellow-800"
                            "confirmed" -> "bg-green-100 text-green-800"
                            "cancelled" -> "bg-red-100 text-red-800"
                            "completed" -> "bg-blue-100 text-blue-800"
                            _ -> "bg-gray-100 text-gray-800"
                          end
                        ]}>
                          {Reservation.status_name(reservation.status)}
                        </span>
                      </div>
                      
    <!-- Reservation Details -->
                      <div class="grid grid-cols-2 lg:grid-cols-4 gap-4 text-sm">
                        <div class="flex items-center text-gray-600">
                          <.icon name="hero-calendar-days" class="w-4 h-4 mr-2" />
                          {Calendar.strftime(reservation.reservation_date, "%d/%m/%Y")}
                        </div>
                        <div class="flex items-center text-gray-600">
                          <.icon name="hero-clock" class="w-4 h-4 mr-2" />
                          {Calendar.strftime(reservation.reservation_time, "%H:%M")}
                        </div>
                        <div class="flex items-center text-gray-600">
                          <.icon name="hero-user-group" class="w-4 h-4 mr-2" />
                          {reservation.party_size} personas
                        </div>
                        <div class="flex items-center text-gray-600">
                          <.icon name="hero-user" class="w-4 h-4 mr-2" />
                          {reservation.customer_name}
                        </div>
                      </div>

                      <%= if reservation.special_requests && reservation.special_requests != "" do %>
                        <div class="mt-3 p-3 bg-blue-50 rounded-lg">
                          <div class="flex items-start">
                            <.icon
                              name="hero-chat-bubble-left-ellipsis"
                              class="w-4 h-4 mr-2 text-blue-600 mt-0.5"
                            />
                            <div>
                              <p class="text-sm font-medium text-blue-900">Solicitudes especiales:</p>
                              <p class="text-sm text-blue-800">{reservation.special_requests}</p>
                            </div>
                          </div>
                        </div>
                      <% end %>
                    </div>
                    
    <!-- Actions -->
                    <div class="flex flex-col sm:flex-row gap-2 lg:ml-6">
                      <.link
                        navigate={~p"/restaurants/#{reservation.restaurant}"}
                        class="inline-flex items-center justify-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-lg text-gray-700 bg-white hover:bg-gray-50"
                      >
                        <.icon name="hero-eye" class="w-4 h-4 mr-2" /> Ver Restaurante
                      </.link>

                      <%= if reservation.status == "confirmed" do %>
                        <%= if is_nil(reservation.order) do %>
                          <.link
                            navigate={~p"/reservations/#{reservation.id}/order"}
                            class="inline-flex items-center justify-center px-4 py-2 border border-transparent text-sm font-medium rounded-lg text-white bg-orange-600 hover:bg-orange-700"
                          >
                            <.icon name="hero-shopping-bag" class="w-4 h-4 mr-2" /> Pre-ordenar Comida
                          </.link>
                        <% else %>
                          <.link
                            navigate={~p"/reservations/#{reservation.id}/order"}
                            class="inline-flex items-center justify-center px-4 py-2 border border-transparent text-sm font-medium rounded-lg text-white bg-green-600 hover:bg-green-700"
                          >
                            <.icon name="hero-shopping-bag" class="w-4 h-4 mr-2" /> Ver Pedido
                          </.link>
                        <% end %>
                      <% end %>

                      <%= if reservation.status in ["pending", "confirmed"] do %>
                        <button
                          phx-click="cancel_reservation"
                          phx-value-id={reservation.id}
                          data-confirm="¿Estás seguro de que quieres cancelar esta reserva?"
                          class="inline-flex items-center justify-center px-4 py-2 border border-red-300 text-sm font-medium rounded-lg text-red-700 bg-white hover:bg-red-50"
                        >
                          <.icon name="hero-x-mark" class="w-4 h-4 mr-2" /> Cancelar
                        </button>
                      <% end %>

                      <%= if reservation.status == "completed" do %>
                        <.link
                          navigate={~p"/reservations/#{reservation.id}/review"}
                          class="inline-flex items-center justify-center px-4 py-2 border border-transparent text-sm font-medium rounded-lg text-white bg-yellow-600 hover:bg-yellow-700"
                        >
                          <.icon name="hero-star" class="w-4 h-4 mr-2" /> Calificar Restaurante
                        </.link>
                        <.link
                          navigate={~p"/restaurants/#{reservation.restaurant}/reserve"}
                          class="inline-flex items-center justify-center px-4 py-2 border border-transparent text-sm font-medium rounded-lg text-white bg-green-600 hover:bg-green-700"
                        >
                          <.icon name="hero-arrow-path" class="w-4 h-4 mr-2" /> Reservar Otra Vez
                        </.link>
                      <% end %>
                    </div>
                  </div>
                </div>
              </div>
            <% end %>
          </div>
        <% end %>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    # Precargar reservaciones con sus órdenes asociadas
    reservations = Reservations.list_user_reservations(socket.assigns.current_scope, [:order])

    # Calcular contadores por estado
    total_count = length(reservations)
    pending_count = Enum.count(reservations, &(&1.status == "pending"))
    confirmed_count = Enum.count(reservations, &(&1.status == "confirmed"))

    {:ok,
     socket
     |> assign(:page_title, "Mis Reservas")
     |> assign(:reservations, reservations)
     |> assign(:filtered_reservations, reservations)
     |> assign(:filter_status, "all")
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
  def handle_event("cancel_reservation", %{"id" => id}, socket) do
    reservation = Enum.find(socket.assigns.reservations, &(&1.id == String.to_integer(id)))

    case Reservations.update_reservation(socket.assigns.current_scope, reservation, %{
           "status" => "cancelled"
         }) do
      {:ok, updated_reservation} ->
        # Actualizar la lista de reservas
        updated_reservations =
          Enum.map(socket.assigns.reservations, fn r ->
            if r.id == updated_reservation.id, do: updated_reservation, else: r
          end)

        # Recalcular contadores
        pending_count = Enum.count(updated_reservations, &(&1.status == "pending"))
        confirmed_count = Enum.count(updated_reservations, &(&1.status == "confirmed"))

        # Aplicar filtro actual
        filtered_reservations =
          case socket.assigns.filter_status do
            "all" -> updated_reservations
            status -> Enum.filter(updated_reservations, &(&1.status == status))
          end

        {:noreply,
         socket
         |> put_flash(:info, "Reserva cancelada exitosamente")
         |> assign(:reservations, updated_reservations)
         |> assign(:filtered_reservations, filtered_reservations)
         |> assign(:pending_count, pending_count)
         |> assign(:confirmed_count, confirmed_count)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "No se pudo cancelar la reserva")}
    end
  end

  # Handle real-time notifications
  handle_notifications()
end
