defmodule FoodReserveWeb.OrderLive.New do
  use FoodReserveWeb, :live_view
  import FoodReserveWeb.LiveHelpers

  alias FoodReserve.Reservations
  alias FoodReserve.Restaurants

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app
      flash={@flash}
      current_scope={@current_scope}
      unread_notifications_count={@unread_notifications_count}
    >
      <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <!-- Header -->
        <div class="bg-white shadow-sm rounded-lg border border-gray-200 mb-6">
          <div class="px-6 py-8 sm:px-8">
            <div class="flex items-center justify-between">
              <div>
                <h1 class="text-3xl font-bold text-gray-900 mb-2">
                  Pedido anticipado
                </h1>
                <p class="text-gray-600 text-lg">
                  Para tu reserva en <span class="font-semibold">{@restaurant.name}</span>
                </p>
                <p class="text-sm text-gray-500 mt-1">
                  <.icon name="hero-calendar" class="w-4 h-4 inline mr-1" />
                  {Calendar.strftime(@reservation.reservation_date, "%d/%m/%Y")} - {Calendar.strftime(
                    @reservation.reservation_time,
                    "%H:%M"
                  )}
                </p>
              </div>
            </div>
          </div>
        </div>
        
    <!-- Order Form -->
        <.live_component
          module={FoodReserveWeb.OrderLive.OrderFormComponent}
          id="order-form"
          reservation={@reservation}
          restaurant_id={@restaurant.id}
          return_to={~p"/my-reservations"}
        />
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"reservation_id" => reservation_id}, _session, socket) do
    reservation = Reservations.get_reservation!(socket.assigns.current_scope, reservation_id)
    restaurant = Restaurants.get_restaurant!(reservation.restaurant_id)

    # Verificar que la reserva pertenezca al usuario actual
    if reservation.user_id != socket.assigns.current_scope.user.id do
      {:ok,
       socket
       |> put_flash(:error, "No tienes permiso para ver esta reserva.")
       |> push_navigate(to: ~p"/my-reservations")}
    else
      {:ok,
       socket
       |> assign(:page_title, "Pedido anticipado")
       |> assign(:reservation, reservation)
       |> assign(:restaurant, restaurant)}
    end
  end

  @impl true
  def handle_info({FoodReserveWeb.OrderLive.OrderFormComponent, {:order_saved, _order}}, socket) do
    {:noreply,
     socket
     |> put_flash(:info, "¡Tu pedido ha sido registrado exitosamente!")
     |> push_navigate(to: ~p"/my-reservations")}
  end

  # Handle real-time notifications
  handle_notifications()
end
