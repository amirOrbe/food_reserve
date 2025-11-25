defmodule FoodReserveWeb.MenuLive.Index do
  use FoodReserveWeb, :live_view

  alias FoodReserve.Restaurants
  alias FoodReserve.Menus

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <!-- Header -->
        <div class="bg-white shadow-sm rounded-lg border border-gray-200 mb-6">
          <div class="px-6 py-8 sm:px-8">
            <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between">
              <div class="mb-4 sm:mb-0">
                <h1 class="text-3xl font-bold text-gray-900 mb-2">
                  Menú de {@restaurant.name}
                </h1>
                <p class="text-gray-600">Gestiona los elementos del menú de tu restaurante</p>
              </div>

              <div class="flex flex-col sm:flex-row gap-3">
                <.link
                  navigate={~p"/restaurants/#{@restaurant}"}
                  class="inline-flex justify-center items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-lg text-gray-700 bg-white hover:bg-gray-50"
                >
                  <.icon name="hero-arrow-left" class="w-4 h-4 mr-2" /> Volver al Restaurante
                </.link>

                <.link
                  navigate={~p"/restaurants/#{@restaurant}/menu/new"}
                  class="inline-flex justify-center items-center px-4 py-2 border border-transparent text-sm font-medium rounded-lg text-white bg-orange-600 hover:bg-orange-700"
                >
                  <.icon name="hero-plus" class="w-4 h-4 mr-2" /> Agregar Elemento
                </.link>
              </div>
            </div>
          </div>
        </div>
        
    <!-- Menu Items -->
        <div class="bg-white shadow-sm rounded-lg border border-gray-200">
          <div class="px-6 py-8 sm:px-8">
            <%= if Enum.empty?(@menu_items) do %>
              <div class="text-center py-12">
                <div class="mx-auto w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mb-4">
                  <.icon name="hero-document-text" class="w-8 h-8 text-gray-400" />
                </div>
                <h3 class="text-lg font-medium text-gray-900 mb-2">
                  Tu menú está vacío
                </h3>
                <p class="text-gray-500 mb-6">
                  Comienza agregando elementos a tu menú para que los clientes puedan verlos.
                </p>
                <.link
                  navigate={~p"/restaurants/#{@restaurant}/menu/new"}
                  class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-orange-600 hover:bg-orange-700"
                >
                  <.icon name="hero-plus" class="w-4 h-4 mr-2" /> Agregar Primer Elemento
                </.link>
              </div>
            <% else %>
              <div class="space-y-8">
                <%= for {category, items} <- @grouped_menu_items do %>
                  <div>
                    <h3 class="text-lg font-medium text-gray-900 mb-4 pb-2 border-b border-gray-200">
                      {category}
                    </h3>
                    <div class="grid gap-4">
                      <%= for item <- items do %>
                        <div class="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
                          <div class="flex-1">
                            <div class="flex items-center gap-3 mb-2">
                              <h4 class="font-medium text-gray-900">{item.name}</h4>
                              <%= unless item.available do %>
                                <span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-red-100 text-red-800">
                                  No disponible
                                </span>
                              <% end %>
                            </div>
                            <p class="text-sm text-gray-600 mb-2">{item.description}</p>
                            <div class="flex items-center gap-4">
                              <span class="text-lg font-semibold text-orange-600">
                                ${:erlang.float_to_binary(Decimal.to_float(item.price), decimals: 2)}
                              </span>
                              <span class="text-sm text-gray-500">
                                Categoría: {item.category || "Sin categoría"}
                              </span>
                            </div>
                          </div>
                          <div class="flex items-center gap-2 ml-4">
                            <.link
                              navigate={~p"/restaurants/#{@restaurant}/menu/#{item}/edit"}
                              class="inline-flex items-center px-3 py-1 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50"
                            >
                              <.icon name="hero-pencil" class="w-4 h-4 mr-1" /> Editar
                            </.link>
                            <button
                              phx-click="delete_item"
                              phx-value-id={item.id}
                              data-confirm="¿Estás seguro de que quieres eliminar este elemento del menú?"
                              class="inline-flex items-center px-3 py-1 border border-red-300 text-sm font-medium rounded-md text-red-700 bg-white hover:bg-red-50"
                            >
                              <.icon name="hero-trash" class="w-4 h-4 mr-1" /> Eliminar
                            </button>
                          </div>
                        </div>
                      <% end %>
                    </div>
                  </div>
                <% end %>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"restaurant_id" => restaurant_id}, _session, socket) do
    restaurant = Restaurants.get_restaurant!(socket.assigns.current_scope, restaurant_id)

    menu_items =
      Menus.list_menu_items_by_restaurant_scoped(socket.assigns.current_scope, restaurant.id)

    {:ok,
     socket
     |> assign(:page_title, "Gestionar Menú")
     |> assign(:restaurant, restaurant)
     |> assign(:menu_items, menu_items)
     |> assign(:grouped_menu_items, group_menu_items_by_category(menu_items))}
  end

  @impl true
  def handle_event("delete_item", %{"id" => id}, socket) do
    menu_item = Menus.get_menu_item!(socket.assigns.current_scope, id)
    {:ok, _} = Menus.delete_menu_item(socket.assigns.current_scope, menu_item)

    # Recargar los elementos del menú
    menu_items =
      Menus.list_menu_items_by_restaurant_scoped(
        socket.assigns.current_scope,
        socket.assigns.restaurant.id
      )

    {:noreply,
     socket
     |> put_flash(:info, "Elemento eliminado exitosamente")
     |> assign(:menu_items, menu_items)
     |> assign(:grouped_menu_items, group_menu_items_by_category(menu_items))}
  end

  defp group_menu_items_by_category(menu_items) do
    menu_items
    |> Enum.group_by(fn item -> item.category || "Sin categoría" end)
    |> Enum.sort_by(fn {category, _items} -> category end)
  end
end
