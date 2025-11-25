defmodule FoodReserveWeb.MenuLive.Form do
  use FoodReserveWeb, :live_view

  alias FoodReserve.Restaurants
  alias FoodReserve.Menus
  alias FoodReserve.Menus.MenuItem

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <!-- Header -->
        <div class="bg-white shadow-sm rounded-lg border border-gray-200 mb-6">
          <div class="px-6 py-8 sm:px-8">
            <div class="flex items-center justify-between">
              <div>
                <h1 class="text-3xl font-bold text-gray-900 mb-2">
                  {if @live_action == :new,
                    do: "Agregar Elemento al Menú",
                    else: "Editar Elemento del Menú"}
                </h1>
                <p class="text-gray-600">Restaurante: {@restaurant.name}</p>
              </div>
              <.link
                navigate={~p"/restaurants/#{@restaurant}/menu"}
                class="inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-lg text-gray-700 bg-white hover:bg-gray-50"
              >
                <.icon name="hero-arrow-left" class="w-4 h-4 mr-2" /> Volver
              </.link>
            </div>
          </div>
        </div>
        
    <!-- Form -->
        <div class="bg-white shadow-sm rounded-lg border border-gray-200">
          <div class="px-6 py-8 sm:px-8">
            <.form
              for={@form}
              id="menu-item-form"
              phx-submit="save"
              class="space-y-6"
            >
              <div class="grid grid-cols-1 gap-6 sm:grid-cols-2">
                <div class="sm:col-span-2">
                  <.input
                    field={@form[:name]}
                    type="text"
                    label="Nombre del plato"
                    placeholder="Ej: Pasta Carbonara"
                    required
                  />
                </div>

                <div>
                  <.input
                    field={@form[:price]}
                    type="number"
                    label="Precio"
                    placeholder="0.00"
                    step="0.01"
                    min="0"
                    required
                  />
                </div>

                <div>
                  <.input
                    field={@form[:category]}
                    type="text"
                    label="Categoría"
                    placeholder="Ej: Entradas, Platos principales, Postres"
                  />
                </div>

                <div class="sm:col-span-2">
                  <.input
                    field={@form[:description]}
                    type="textarea"
                    label="Descripción"
                    placeholder="Describe los ingredientes y preparación del plato..."
                    rows="4"
                    required
                  />
                </div>

                <div class="sm:col-span-2">
                  <div class="flex items-center">
                    <.input
                      field={@form[:available]}
                      type="checkbox"
                      label="Disponible para pedidos"
                    />
                  </div>
                  <p class="mt-1 text-sm text-gray-500">
                    Desmarca esta opción si el plato no está disponible temporalmente
                  </p>
                </div>
              </div>

              <div class="flex justify-end gap-3 pt-6 border-t border-gray-200">
                <.link
                  navigate={~p"/restaurants/#{@restaurant}/menu"}
                  class="inline-flex justify-center items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-lg text-gray-700 bg-white hover:bg-gray-50"
                >
                  Cancelar
                </.link>
                <.button
                  type="submit"
                  class="inline-flex justify-center items-center px-4 py-2 border border-transparent text-sm font-medium rounded-lg text-white bg-orange-600 hover:bg-orange-700"
                >
                  {if @live_action == :new, do: "Agregar Elemento", else: "Guardar Cambios"}
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
  def mount(%{"restaurant_id" => restaurant_id} = params, _session, socket) do
    restaurant = Restaurants.get_restaurant!(socket.assigns.current_scope, restaurant_id)

    # Obtener o crear el menú del restaurante
    menu = get_or_create_menu(restaurant, socket.assigns.current_scope)

    {menu_item, changeset} =
      case socket.assigns.live_action do
        :new ->
          menu_item = %MenuItem{menu_id: menu.id, available: true}
          {menu_item, Menus.change_menu_item(menu_item)}

        :edit ->
          menu_item = Menus.get_menu_item!(socket.assigns.current_scope, params["id"])
          {menu_item, Menus.change_menu_item(menu_item)}
      end

    {:ok,
     socket
     |> assign(
       :page_title,
       if(socket.assigns.live_action == :new, do: "Nuevo Elemento", else: "Editar Elemento")
     )
     |> assign(:restaurant, restaurant)
     |> assign(:menu, menu)
     |> assign(:menu_item, menu_item)
     |> assign(:form, to_form(changeset))}
  end

  @impl true
  def handle_event("save", %{"menu_item" => menu_item_params}, socket) do
    save_menu_item(socket, socket.assigns.live_action, menu_item_params)
  end

  defp save_menu_item(socket, :new, menu_item_params) do
    menu_item_params = Map.put(menu_item_params, "menu_id", socket.assigns.menu.id)

    case Menus.create_menu_item(socket.assigns.current_scope, menu_item_params) do
      {:ok, _menu_item} ->
        {:noreply,
         socket
         |> put_flash(:info, "Elemento agregado exitosamente")
         |> push_navigate(to: ~p"/restaurants/#{socket.assigns.restaurant}/menu")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  defp save_menu_item(socket, :edit, menu_item_params) do
    case Menus.update_menu_item(
           socket.assigns.current_scope,
           socket.assigns.menu_item,
           menu_item_params
         ) do
      {:ok, _menu_item} ->
        {:noreply,
         socket
         |> put_flash(:info, "Elemento actualizado exitosamente")
         |> push_navigate(to: ~p"/restaurants/#{socket.assigns.restaurant}/menu")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  defp get_or_create_menu(restaurant, scope) do
    case Menus.get_menu_by_restaurant(restaurant.id) do
      nil ->
        {:ok, menu} =
          Menus.create_menu(scope, %{
            name: "Menú de #{restaurant.name}",
            restaurant_id: restaurant.id
          })

        menu

      menu ->
        menu
    end
  end
end
