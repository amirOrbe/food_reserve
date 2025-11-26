defmodule FoodReserveWeb.OrderLive.UserIndex do
  use FoodReserveWeb, :live_view
  alias FoodReserve.Orders

  @impl true
  def mount(_params, _session, socket) do
    current_scope = socket.assigns.current_scope

    orders = Orders.list_user_orders(current_scope)

    {:ok,
     socket
     |> assign(:page_title, "Mis Pedidos")
     |> assign(:orders, orders)}
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
        <div class="sm:flex sm:items-center">
          <div class="sm:flex-auto">
            <h1 class="text-3xl font-semibold text-gray-900">Mis Pedidos</h1>
            <p class="mt-2 text-sm text-gray-700">Historial de tus pedidos para llevar.</p>
          </div>
        </div>

        <div class="mt-8 flex flex-col">
          <%= if Enum.empty?(@orders) do %>
            <div class="py-12 text-center">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="mx-auto h-12 w-12 text-gray-400"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z"
                />
              </svg>
              <h3 class="mt-2 text-sm font-medium text-gray-900">No tienes pedidos</h3>
              <p class="mt-1 text-sm text-gray-500">
                Comienza pidiendo comida para llevar en tu restaurante favorito.
              </p>
              <div class="mt-6">
                <.link
                  navigate={~p"/restaurants"}
                  class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
                >
                  Ver Restaurantes
                </.link>
              </div>
            </div>
          <% else %>
            <div class="overflow-x-auto">
              <div class="inline-block min-w-full py-2 align-middle">
                <div class="overflow-hidden shadow ring-1 ring-black ring-opacity-5 md:rounded-lg">
                  <table class="min-w-full divide-y divide-gray-300">
                    <thead class="bg-gray-50">
                      <tr>
                        <th
                          scope="col"
                          class="py-3.5 pl-4 pr-3 text-left text-sm font-semibold text-gray-900 sm:pl-6"
                        >
                          Restaurante
                        </th>
                        <th
                          scope="col"
                          class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900"
                        >
                          Fecha
                        </th>
                        <th
                          scope="col"
                          class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900"
                        >
                          Hora
                        </th>
                        <th
                          scope="col"
                          class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900"
                        >
                          Estado
                        </th>
                        <th
                          scope="col"
                          class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900"
                        >
                          Total
                        </th>
                        <th scope="col" class="relative py-3.5 pl-3 pr-4 sm:pr-6">
                          <span class="sr-only">Acciones</span>
                        </th>
                      </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-200 bg-white">
                      <%= for order <- @orders do %>
                        <tr>
                          <td class="whitespace-nowrap py-4 pl-4 pr-3 text-sm font-medium text-gray-900 sm:pl-6">
                            <%= if order.restaurant do %>
                              {order.restaurant.name}
                            <% else %>
                              <span class="text-gray-500">No disponible</span>
                            <% end %>
                          </td>
                          <td class="whitespace-nowrap px-3 py-4 text-sm text-gray-500">
                            {format_date(order.pickup_date)}
                          </td>
                          <td class="whitespace-nowrap px-3 py-4 text-sm text-gray-500">
                            {format_time(order.pickup_time)}
                          </td>
                          <td class="whitespace-nowrap px-3 py-4 text-sm">
                            <%= case order.status do %>
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
                                  {order.status}
                                </span>
                            <% end %>
                          </td>
                          <td class="whitespace-nowrap px-3 py-4 text-sm text-gray-500">
                            ${order.total_amount}
                          </td>
                          <td class="relative whitespace-nowrap py-4 pl-3 pr-4 text-right text-sm font-medium sm:pr-6">
                            <div class="flex space-x-3 justify-end">
                              <.link
                                navigate={~p"/orders/#{order.id}"}
                                class="text-blue-600 hover:text-blue-900"
                              >
                                Ver detalles<span class="sr-only">, pedido <%= order.id %></span>
                              </.link>
                              <%= if order.status == "pending" and order.order_type == "pickup" do %>
                                <.link
                                  navigate={~p"/orders/#{order.id}/edit"}
                                  class="text-green-600 hover:text-green-900"
                                >
                                  Editar<span class="sr-only">, pedido <%= order.id %></span>
                                </.link>
                              <% end %>
                            </div>
                          </td>
                        </tr>
                      <% end %>
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
          <% end %>
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
end
