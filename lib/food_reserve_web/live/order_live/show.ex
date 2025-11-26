defmodule FoodReserveWeb.OrderLive.Show do
  use FoodReserveWeb, :live_view
  alias FoodReserve.Orders

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
        # Verificar que el usuario es dueño del pedido
        if order.user_id == current_scope.user.id do
          {:ok,
           socket
           |> assign(:page_title, "Detalle de Pedido ##{order.id}")
           |> assign(:order, order)}
        else
          {:ok,
           socket
           |> put_flash(:error, "No tienes permiso para ver este pedido")
           |> push_navigate(to: ~p"/my-orders")}
        end
    end
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
          <div class="flex items-center justify-between">
            <div>
              <h1 class="text-2xl font-bold text-gray-900">Pedido #{@order.id}</h1>
              <p class="mt-1 text-sm text-gray-500">
                Realizado el {format_datetime(@order.inserted_at)}
              </p>
            </div>
            <div class="flex items-center gap-4">
              <%= if @order.status == "pending" and @order.order_type == "pickup" do %>
                <.link
                  navigate={~p"/orders/#{@order.id}/edit"}
                  class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-blue-600 hover:bg-blue-700"
                >
                  <.icon name="hero-pencil" class="w-4 h-4 mr-2" /> Editar pedido
                </.link>
              <% end %>
              <.link
                navigate={~p"/my-orders"}
                class="text-sm font-medium text-blue-600 hover:text-blue-500"
              >
                ← Volver a mis pedidos
              </.link>
            </div>
          </div>
          
    <!-- Estado del pedido -->
          <div class="mt-6">
            <div class="bg-white shadow overflow-hidden sm:rounded-lg">
              <div class="px-4 py-5 sm:px-6">
                <h3 class="text-lg leading-6 font-medium text-gray-900">Estado del Pedido</h3>
              </div>
              <div class="border-t border-gray-200 px-4 py-5 sm:p-0">
                <dl class="sm:divide-y sm:divide-gray-200">
                  <div class="py-4 sm:py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
                    <dt class="text-sm font-medium text-gray-500">Estado</dt>
                    <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">
                      <%= case @order.status do %>
                        <% "pending" -> %>
                          <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-yellow-100 text-yellow-800">
                            Pendiente
                          </span>
                        <% "confirmed" -> %>
                          <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                            Confirmado
                          </span>
                        <% "rejected" -> %>
                          <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800">
                            Rechazado
                          </span>
                        <% "completed" -> %>
                          <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                            Completado
                          </span>
                        <% _ -> %>
                          <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800">
                            {@order.status}
                          </span>
                      <% end %>
                    </dd>
                  </div>
                  <div class="py-4 sm:py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
                    <dt class="text-sm font-medium text-gray-500">Restaurante</dt>
                    <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">
                      <%= if @order.restaurant do %>
                        {@order.restaurant.name}
                      <% else %>
                        <span class="text-gray-500">No disponible</span>
                      <% end %>
                    </dd>
                  </div>
                  <div class="py-4 sm:py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
                    <dt class="text-sm font-medium text-gray-500">Fecha de recogida</dt>
                    <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">
                      {format_date(@order.pickup_date)}
                    </dd>
                  </div>
                  <div class="py-4 sm:py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
                    <dt class="text-sm font-medium text-gray-500">Hora de recogida</dt>
                    <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">
                      {format_time(@order.pickup_time)}
                    </dd>
                  </div>
                  <div class="py-4 sm:py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
                    <dt class="text-sm font-medium text-gray-500">Nombre para recogida</dt>
                    <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">
                      {@order.pickup_name}
                    </dd>
                  </div>
                  <div class="py-4 sm:py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
                    <dt class="text-sm font-medium text-gray-500">Teléfono de contacto</dt>
                    <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">
                      {@order.pickup_phone}
                    </dd>
                  </div>
                  <%= if @order.special_instructions && String.trim(@order.special_instructions) != "" do %>
                    <div class="py-4 sm:py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
                      <dt class="text-sm font-medium text-gray-500">Instrucciones especiales</dt>
                      <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">
                        {@order.special_instructions}
                      </dd>
                    </div>
                  <% end %>
                </dl>
              </div>
            </div>
          </div>
          
    <!-- Detalle del pedido -->
          <div class="mt-8">
            <div class="bg-white shadow overflow-hidden sm:rounded-lg">
              <div class="px-4 py-5 sm:px-6">
                <h3 class="text-lg leading-6 font-medium text-gray-900">Artículos del Pedido</h3>
              </div>
              <div class="border-t border-gray-200">
                <div class="bg-white shadow overflow-hidden sm:rounded-lg">
                  <table class="min-w-full divide-y divide-gray-200">
                    <thead class="bg-gray-50">
                      <tr>
                        <th
                          scope="col"
                          class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                        >
                          Artículo
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
                          Subtotal
                        </th>
                      </tr>
                    </thead>
                    <tbody class="bg-white divide-y divide-gray-200">
                      <%= for item <- @order.order_items do %>
                        <tr>
                          <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                            <%= if item.menu_item do %>
                              {item.menu_item.name}
                            <% else %>
                              <span class="text-gray-500">Producto no disponible</span>
                            <% end %>
                          </td>
                          <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                            {item.quantity}
                          </td>
                          <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                            ${item.price}
                          </td>
                          <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                            ${Decimal.mult(item.price, item.quantity)}
                          </td>
                        </tr>
                      <% end %>
                      <tr class="bg-gray-50">
                        <td
                          colspan="3"
                          class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 text-right"
                        >
                          Total:
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm font-bold text-gray-900">
                          ${@order.total_amount}
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  # Funciones auxiliares para formatear fechas y horas
  defp format_date(date) do
    Calendar.strftime(date, "%d/%m/%Y")
  end

  defp format_time(time) do
    Calendar.strftime(time, "%H:%M")
  end

  defp format_datetime(datetime) do
    Calendar.strftime(datetime, "%d/%m/%Y %H:%M")
  end
end
