defmodule FoodReserveWeb.OrderLive.Manage do
  use FoodReserveWeb, :live_view
  import FoodReserveWeb.LiveHelpers

  alias FoodReserve.Orders

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app
      flash={@flash}
      current_scope={@current_scope}
      unread_notifications_count={@unread_notifications_count}
    >
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <!-- Header -->
        <div class="bg-white shadow-sm rounded-lg border border-gray-200 mb-6">
          <div class="px-6 py-8 sm:px-8">
            <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between">
              <div class="mb-4 sm:mb-0">
                <h1 class="text-3xl font-bold text-gray-900 mb-2">
                  Pedidos Anticipados
                </h1>
                <p class="text-gray-600">
                  Gestiona los pedidos de comida pre-ordenados por tus clientes
                </p>
              </div>
            </div>
            
    <!-- Filter Controls -->
            <div class="mt-6">
              <div class="flex flex-wrap items-center gap-3">
                <span class="text-sm font-medium text-gray-700 mr-2">Filtrar por:</span>

                <div class="flex flex-wrap gap-2">
                  <button
                    phx-click="filter_status"
                    phx-value-status="all"
                    class={"px-3 py-2 rounded-lg text-sm font-medium " <> if(@filter_status == "all", do: "bg-blue-600 text-white", else: "bg-gray-100 text-gray-700 hover:bg-gray-200")}
                  >
                    Todos
                  </button>
                  <button
                    phx-click="filter_status"
                    phx-value-status="pending"
                    class={"px-3 py-2 rounded-lg text-sm font-medium " <> if(@filter_status == "pending", do: "bg-yellow-600 text-white", else: "bg-gray-100 text-gray-700 hover:bg-gray-200")}
                  >
                    Pendientes
                  </button>
                  <button
                    phx-click="filter_status"
                    phx-value-status="confirmed"
                    class={"px-3 py-2 rounded-lg text-sm font-medium " <> if(@filter_status == "confirmed", do: "bg-blue-600 text-white", else: "bg-gray-100 text-gray-700 hover:bg-gray-200")}
                  >
                    Confirmados
                  </button>
                  <button
                    phx-click="filter_status"
                    phx-value-status="preparing"
                    class={"px-3 py-2 rounded-lg text-sm font-medium " <> if(@filter_status == "preparing", do: "bg-purple-600 text-white", else: "bg-gray-100 text-gray-700 hover:bg-gray-200")}
                  >
                    En preparación
                  </button>
                  <button
                    phx-click="filter_status"
                    phx-value-status="ready"
                    class={"px-3 py-2 rounded-lg text-sm font-medium " <> if(@filter_status == "ready", do: "bg-green-600 text-white", else: "bg-gray-100 text-gray-700 hover:bg-gray-200")}
                  >
                    Listos
                  </button>
                </div>

                <div class="ml-4 border-l border-gray-300 pl-4">
                  <span class="text-sm font-medium text-gray-700 mr-2">Tipo:</span>
                  <div class="flex flex-wrap gap-2 mt-2 sm:mt-0">
                    <button
                      phx-click="filter_order_type"
                      phx-value-type="all"
                      class={"px-3 py-2 rounded-lg text-sm font-medium " <> if(@filter_order_type == "all", do: "bg-blue-600 text-white", else: "bg-gray-100 text-gray-700 hover:bg-gray-200")}
                    >
                      Todos
                    </button>
                    <button
                      phx-click="filter_order_type"
                      phx-value-type="dine_in"
                      class={"px-3 py-2 rounded-lg text-sm font-medium " <> if(@filter_order_type == "dine_in", do: "bg-green-600 text-white", else: "bg-gray-100 text-gray-700 hover:bg-gray-200")}
                    >
                      <.icon name="hero-calendar" class="w-4 h-4 mr-1" /> En restaurante
                    </button>
                    <button
                      phx-click="filter_order_type"
                      phx-value-type="pickup"
                      class={"px-3 py-2 rounded-lg text-sm font-medium " <> if(@filter_order_type == "pickup", do: "bg-orange-600 text-white", else: "bg-gray-100 text-gray-700 hover:bg-gray-200")}
                    >
                      <.icon name="hero-shopping-bag" class="w-4 h-4 mr-1" /> Para llevar
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        
    <!-- Orders List -->
        <%= if Enum.empty?(@filtered_orders) do %>
          <div class="text-center py-12 bg-white rounded-lg shadow-sm">
            <div class="mx-auto w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mb-4">
              <.icon name="hero-shopping-bag" class="w-8 h-8 text-gray-400" />
            </div>
            <h3 class="text-lg font-medium text-gray-900 mb-2">No hay pedidos anticipados</h3>
            <p class="text-gray-500">
              <%= case @filter_status do %>
                <% "all" -> %>
                  Aún no hay pedidos anticipados para tus reservas.
                <% "pending" -> %>
                  No hay pedidos pendientes por confirmar.
                <% "confirmed" -> %>
                  No hay pedidos confirmados.
                <% "preparing" -> %>
                  No hay pedidos en preparación.
                <% "ready" -> %>
                  No hay pedidos listos para servir.
                <% _ -> %>
                  No hay pedidos con el filtro seleccionado.
              <% end %>
            </p>
          </div>
        <% else %>
          <div class="space-y-6">
            <%= for order <- @filtered_orders do %>
              <div class="bg-white shadow-sm rounded-lg border border-gray-200 overflow-hidden">
                <div class="px-6 py-4 border-b border-gray-200 bg-gray-50">
                  <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                    <div>
                      <%= if order.order_type == "dine_in" do %>
                        <div class="flex items-center">
                          <.icon name="hero-calendar" class="w-4 h-4 text-gray-500 mr-2" />
                          <span class="text-sm text-gray-700">
                            Reserva para el {Calendar.strftime(
                              order.reservation.reservation_date,
                              "%d/%m/%Y"
                            )} a las {Calendar.strftime(order.reservation.reservation_time, "%H:%M")}
                          </span>
                        </div>
                        <div class="flex items-center mt-1">
                          <.icon name="hero-user" class="w-4 h-4 text-gray-500 mr-2" />
                          <span class="text-sm text-gray-700">
                            {order.reservation.customer_name} - {order.reservation.customer_phone}
                          </span>
                        </div>
                      <% else %>
                        <div class="flex items-center">
                          <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-orange-100 text-orange-800 mr-2">
                            <.icon name="hero-shopping-bag" class="w-3 h-3 mr-1" /> Para llevar
                          </span>
                          <span class="text-sm text-gray-700">
                            Recogida el {Calendar.strftime(
                              order.pickup_date,
                              "%d/%m/%Y"
                            )} a las {Calendar.strftime(order.pickup_time, "%H:%M")}
                          </span>
                        </div>
                        <div class="flex items-center mt-1">
                          <.icon name="hero-user" class="w-4 h-4 text-gray-500 mr-2" />
                          <span class="text-sm text-gray-700">
                            {order.pickup_name} - {order.pickup_phone}
                          </span>
                        </div>
                      <% end %>
                    </div>

                    <div class="flex items-center gap-4">
                      <span class={[
                        "inline-flex items-center px-3 py-1 rounded-full text-xs font-medium",
                        case order.status do
                          "pending" -> "bg-yellow-100 text-yellow-800"
                          "confirmed" -> "bg-blue-100 text-blue-800"
                          "preparing" -> "bg-purple-100 text-purple-800"
                          "ready" -> "bg-green-100 text-green-800"
                          "completed" -> "bg-gray-100 text-gray-800"
                          "cancelled" -> "bg-red-100 text-red-800"
                          _ -> "bg-gray-100 text-gray-800"
                        end
                      ]}>
                        {case order.status do
                          "pending" -> "Pendiente"
                          "confirmed" -> "Confirmado"
                          "preparing" -> "En preparación"
                          "ready" -> "Listo para servir"
                          "completed" -> "Completado"
                          "cancelled" -> "Cancelado"
                          _ -> "Desconocido"
                        end}
                      </span>

                      <div class="text-lg font-semibold text-gray-800">
                        Total: ${format_price(order.total_amount)}
                      </div>
                    </div>
                  </div>
                </div>

                <div class="p-6">
                  <!-- Order Items -->
                  <h3 class="text-lg font-semibold text-gray-900 mb-4">Elementos del pedido</h3>

                  <div class="overflow-hidden bg-white border border-gray-200 rounded-lg">
                    <table class="min-w-full divide-y divide-gray-200">
                      <thead class="bg-gray-50">
                        <tr>
                          <th
                            scope="col"
                            class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                          >
                            Platillo
                          </th>
                          <th
                            scope="col"
                            class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                          >
                            Cantidad
                          </th>
                          <th
                            scope="col"
                            class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                          >
                            Precio unitario
                          </th>
                          <th
                            scope="col"
                            class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                          >
                            Total
                          </th>
                        </tr>
                      </thead>
                      <tbody class="bg-white divide-y divide-gray-200">
                        <%= for item <- order.order_items do %>
                          <tr>
                            <td class="px-6 py-4">
                              <div class="text-sm font-medium text-gray-900">
                                {item.menu_item.name}
                              </div>
                              <div class="text-sm text-gray-500">{item.menu_item.category}</div>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                              {item.quantity}
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                              ${format_price(item.price)}
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                              ${format_price(Decimal.mult(item.price, Decimal.new(item.quantity)))}
                            </td>
                          </tr>
                        <% end %>
                      </tbody>
                    </table>
                  </div>
                  
    <!-- Special Instructions -->
                  <%= if order.special_instructions && order.special_instructions != "" do %>
                    <div class="mt-6">
                      <h4 class="text-sm font-medium text-gray-700 mb-2">
                        Instrucciones especiales:
                      </h4>
                      <div class="bg-gray-50 p-3 rounded text-sm text-gray-700">
                        {order.special_instructions}
                      </div>
                    </div>
                  <% end %>
                </div>
                
    <!-- Actions -->
                <div class="px-6 py-4 bg-gray-50 border-t border-gray-200">
                  <div class="flex flex-wrap justify-end gap-3">
                    <%= case order.status do %>
                      <% "pending" -> %>
                        <button
                          phx-click="update_order_status"
                          phx-value-id={order.id}
                          phx-value-status="confirmed"
                          class="inline-flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-lg shadow-sm text-white bg-blue-600 hover:bg-blue-700"
                        >
                          <.icon name="hero-check" class="w-4 h-4 mr-2" /> Confirmar
                        </button>
                      <% "confirmed" -> %>
                        <button
                          phx-click="update_order_status"
                          phx-value-id={order.id}
                          phx-value-status="preparing"
                          class="inline-flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-lg shadow-sm text-white bg-purple-600 hover:bg-purple-700"
                        >
                          <.icon name="hero-fire" class="w-4 h-4 mr-2" /> Iniciar preparación
                        </button>
                      <% "preparing" -> %>
                        <button
                          phx-click="update_order_status"
                          phx-value-id={order.id}
                          phx-value-status="ready"
                          class="inline-flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-lg shadow-sm text-white bg-green-600 hover:bg-green-700"
                        >
                          <.icon name="hero-check-badge" class="w-4 h-4 mr-2" /> Marcar listo
                        </button>
                      <% "ready" -> %>
                        <button
                          phx-click="update_order_status"
                          phx-value-id={order.id}
                          phx-value-status="completed"
                          class="inline-flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-lg shadow-sm text-white bg-gray-600 hover:bg-gray-700"
                        >
                          <.icon name="hero-check-circle" class="w-4 h-4 mr-2" /> Completar
                        </button>
                      <% _ -> %>
                        <!-- No actions for completed or cancelled orders -->
                    <% end %>

                    <%= if order.status in ["pending", "confirmed"] do %>
                      <button
                        phx-click="update_order_status"
                        phx-value-id={order.id}
                        phx-value-status="cancelled"
                        data-confirm="¿Estás seguro de que deseas cancelar este pedido?"
                        class="inline-flex justify-center py-2 px-4 border border-gray-300 text-sm font-medium rounded-lg shadow-sm text-red-700 bg-white hover:bg-gray-50"
                      >
                        <.icon name="hero-x-mark" class="w-4 h-4 mr-2" /> Cancelar
                      </button>
                    <% end %>
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
    # Verificar que el usuario es un dueño de restaurante
    if socket.assigns.current_scope.user.role != "restaurant_owner" do
      {:ok,
       socket
       |> put_flash(:error, "No tienes permiso para ver esta página.")
       |> push_navigate(to: ~p"/")}
    else
      # Obtener todos los pedidos de reservaciones en los restaurantes del usuario
      orders = Orders.list_restaurant_owner_orders(socket.assigns.current_scope)

      {:ok,
       socket
       |> assign(:page_title, "Pedidos Anticipados")
       |> assign(:orders, orders)
       |> assign(:filtered_orders, orders)
       |> assign(:filter_status, "all")
       |> assign(:filter_order_type, "all")}
    end
  end

  @impl true
  def handle_event("filter_status", %{"status" => status}, socket) do
    filtered_orders =
      apply_filters(socket.assigns.orders, status, socket.assigns.filter_order_type)

    {:noreply,
     socket
     |> assign(:filter_status, status)
     |> assign(:filtered_orders, filtered_orders)}
  end

  @impl true
  def handle_event("filter_order_type", %{"type" => order_type}, socket) do
    filtered_orders =
      apply_filters(socket.assigns.orders, socket.assigns.filter_status, order_type)

    {:noreply,
     socket
     |> assign(:filter_order_type, order_type)
     |> assign(:filtered_orders, filtered_orders)}
  end

  @impl true
  def handle_event("update_order_status", %{"id" => id, "status" => status}, socket) do
    order = Orders.get_order!(String.to_integer(id))

    case Orders.update_order_status(order, status) do
      {:ok, _updated_order} ->
        # Recargar la lista de pedidos
        orders = Orders.list_restaurant_owner_orders(socket.assigns.current_scope)

        filtered_orders =
          apply_filters(orders, socket.assigns.filter_status, socket.assigns.filter_order_type)

        {:noreply,
         socket
         |> put_flash(:info, "Estado del pedido actualizado exitosamente.")
         |> assign(:orders, orders)
         |> assign(:filtered_orders, filtered_orders)}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "No se pudo actualizar el estado del pedido.")}
    end
  end

  # Función auxiliar para aplicar ambos filtros
  defp apply_filters(orders, status, order_type) do
    orders
    |> filter_by_status(status)
    |> filter_by_type(order_type)
  end

  defp filter_by_status(orders, "all"), do: orders
  defp filter_by_status(orders, status), do: Enum.filter(orders, &(&1.status == status))

  defp filter_by_type(orders, "all"), do: orders
  defp filter_by_type(orders, type), do: Enum.filter(orders, &(&1.order_type == type))

  # Función auxiliar para formatear precios
  defp format_price(price) do
    :erlang.float_to_binary(Decimal.to_float(price), decimals: 2)
  end

  # Handle real-time notifications
  handle_notifications()
end
