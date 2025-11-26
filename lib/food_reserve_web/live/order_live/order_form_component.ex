defmodule FoodReserveWeb.OrderLive.OrderFormComponent do
  use FoodReserveWeb, :live_component

  alias FoodReserve.Orders
  alias FoodReserve.Menus
  alias FoodReserve.Orders.Order

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <span class="text-lg font-semibold">Pre-ordenar Alimentos</span>
        <:subtitle>
          Selecciona platillos para que estén listos cuando llegues al restaurante
        </:subtitle>
      </.header>

      <div class="mb-6"></div>

      <.form for={@form} id="order-form" phx-target={@myself} phx-change="validate" phx-submit="save">
        <div class="mb-4">
          <.input
            type="textarea"
            label="Instrucciones especiales"
            field={@form[:special_instructions]}
            placeholder="Alergias, preferencias, etc."
            class="w-full"
          />
        </div>

        <div class="mb-6">
          <div class="font-medium text-gray-700 mb-2">Menú</div>
          <%= if Enum.empty?(@menu_items) do %>
            <div class="text-gray-500 italic">Este restaurante no tiene platillos disponibles</div>
          <% else %>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <%= for {category, items} <- group_by_category(@menu_items) do %>
                <div class="bg-white p-4 rounded shadow-sm">
                  <h3 class="font-semibold text-gray-800 mb-2">{String.capitalize(category)}</h3>
                  <div class="space-y-3">
                    <%= for item <- items do %>
                      <div class="flex items-center justify-between border-b pb-2">
                        <div>
                          <div class="font-medium">{item.name}</div>
                          <div class="text-sm text-gray-500">{item.description}</div>
                          <div class="text-sm font-semibold mt-1">${format_price(item.price)}</div>
                        </div>
                        <div class="flex items-center">
                          <button
                            type="button"
                            phx-target={@myself}
                            phx-click="decrement"
                            phx-value-id={item.id}
                            class="bg-gray-200 hover:bg-gray-300 text-gray-700 font-bold py-1 px-2 rounded-l"
                          >
                            -
                          </button>
                          <span class="bg-white px-3 py-1 border-t border-b">
                            {get_item_quantity(assigns, item.id)}
                          </span>
                          <button
                            type="button"
                            phx-target={@myself}
                            phx-click="increment"
                            phx-value-id={item.id}
                            class="bg-gray-200 hover:bg-gray-300 text-gray-700 font-bold py-1 px-2 rounded-r"
                          >
                            +
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

        <div class="flex justify-between items-center border-t border-gray-200 pt-4">
          <div class="text-lg font-semibold">
            Total: ${format_price(calculate_total(assigns))}
          </div>
          <.button type="submit" class="btn-primary" disabled={@selected_items_count == 0}>
            Confirmar Pedido
          </.button>
        </div>
      </.form>
    </div>
    """
  end

  @impl true
  def update(%{reservation: reservation, restaurant_id: restaurant_id} = assigns, socket) do
    menu_items = Menus.list_menu_items_for_restaurant(restaurant_id, true)

    # Inicializar el mapa de cantidades como vacío o desde orden existente
    quantities = init_quantities(reservation, menu_items)

    changeset =
      Orders.change_order(%Order{}, %{
        reservation_id: reservation.id,
        status: "pending",
        special_instructions: ""
      })

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:menu_items, menu_items)
     |> assign(:quantities, quantities)
     |> assign(:selected_items_count, Enum.count(quantities, fn {_, qty} -> qty > 0 end))
     |> assign(:form, to_form(changeset))}
  end

  @impl true
  def handle_event("validate", %{"order" => order_params}, socket) do
    changeset =
      %Order{}
      |> Orders.change_order(order_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  @impl true
  def handle_event("save", %{"order" => order_params}, socket) do
    # Solo crear el pedido si hay elementos seleccionados
    if socket.assigns.selected_items_count > 0 do
      # Preparar los elementos del pedido
      order_items =
        Enum.map(socket.assigns.quantities, fn {item_id, qty} ->
          if qty > 0 do
            menu_item = Enum.find(socket.assigns.menu_items, &(&1.id == item_id))

            %{
              menu_item_id: item_id,
              quantity: qty,
              price: menu_item.price,
              notes: ""
            }
          end
        end)
        |> Enum.filter(&(&1 != nil))

      # Crear el pedido
      case Orders.create_order(
             Map.put(order_params, :reservation_id, socket.assigns.reservation.id),
             order_items
           ) do
        {:ok, order} ->
          notify_parent({:order_saved, order})

          {:noreply,
           socket
           |> put_flash(:info, "Pedido creado exitosamente.")
           |> push_patch(to: socket.assigns.return_to)}

        {:error, _} ->
          {:noreply,
           socket
           |> put_flash(:error, "Error al crear el pedido. Por favor intenta nuevamente.")
           |> assign(form: to_form(Orders.change_order(%Order{}, order_params)))}
      end
    else
      {:noreply,
       socket
       |> put_flash(:error, "Debes seleccionar al menos un elemento para hacer un pedido.")}
    end
  end

  @impl true
  def handle_event("increment", %{"id" => id}, socket) do
    item_id = String.to_integer(id)
    quantities = Map.update(socket.assigns.quantities, item_id, 1, &(&1 + 1))
    selected_count = Enum.count(quantities, fn {_, qty} -> qty > 0 end)

    {:noreply,
     socket
     |> assign(:quantities, quantities)
     |> assign(:selected_items_count, selected_count)}
  end

  @impl true
  def handle_event("decrement", %{"id" => id}, socket) do
    item_id = String.to_integer(id)
    current_qty = Map.get(socket.assigns.quantities, item_id, 0)

    if current_qty > 0 do
      quantities = Map.update(socket.assigns.quantities, item_id, 0, &max(0, &1 - 1))
      selected_count = Enum.count(quantities, fn {_, qty} -> qty > 0 end)

      {:noreply,
       socket
       |> assign(:quantities, quantities)
       |> assign(:selected_items_count, selected_count)}
    else
      {:noreply, socket}
    end
  end

  # Función auxiliar para agrupar elementos del menú por categoría
  defp group_by_category(menu_items) do
    menu_items
    |> Enum.group_by(fn item -> item.category end)
  end

  # Función auxiliar para obtener la cantidad de un elemento
  defp get_item_quantity(assigns, item_id) do
    Map.get(assigns.quantities, item_id, 0)
  end

  # Función auxiliar para calcular el total
  defp calculate_total(assigns) do
    Enum.reduce(assigns.quantities, Decimal.new(0), fn {item_id, qty}, acc ->
      if qty > 0 do
        item = Enum.find(assigns.menu_items, &(&1.id == item_id))
        item_total = Decimal.mult(item.price, Decimal.new(qty))
        Decimal.add(acc, item_total)
      else
        acc
      end
    end)
  end

  # Inicializa el mapa de cantidades desde una orden existente o vacío
  defp init_quantities(reservation, menu_items) do
    case Orders.get_order_by_reservation(reservation.id) do
      nil ->
        # Si no hay orden, inicializar todas las cantidades en 0
        menu_items
        |> Enum.map(&{&1.id, 0})
        |> Map.new()

      order ->
        # Si hay una orden existente, inicializar con las cantidades actuales
        items_map =
          order.order_items
          |> Enum.map(&{&1.menu_item_id, &1.quantity})
          |> Map.new()

        # Asegurar que todos los elementos del menú estén en el mapa
        menu_items
        |> Enum.map(&{&1.id, Map.get(items_map, &1.id, 0)})
        |> Map.new()
    end
  end

  # Función auxiliar para formatear precios
  defp format_price(price) do
    :erlang.float_to_binary(Decimal.to_float(price), decimals: 2)
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
