defmodule FoodReserveWeb.OrderLive.PickupNew do
  use FoodReserveWeb, :live_view

  alias FoodReserve.Restaurants
  alias FoodReserve.Menus
  alias FoodReserve.Orders
  alias FoodReserve.Orders.Order
  # Eliminamos aliases no utilizados

  @impl true
  def mount(%{"restaurant_id" => restaurant_id}, _session, socket) do
    _current_scope = socket.assigns.current_scope

    restaurant = Restaurants.get_restaurant!(restaurant_id)
    menu_items = Menus.list_menu_items_by_restaurant(restaurant_id)

    today = local_today()
    working_hours = Restaurants.get_working_hours_for_date(restaurant_id, today)

    available_hours =
      if working_hours && !working_hours.is_closed do
        now = local_time()

        open_time =
          if Time.compare(now, working_hours.open_time) == :lt do
            working_hours.open_time
          else
            %{now | minute: round_to_next_half_hour(now.minute), second: 0, microsecond: {0, 0}}
          end

        generate_available_times(open_time, working_hours.close_time)
      else
        []
      end

    changeset =
      Orders.change_order(%Order{
        order_type: "pickup",
        pickup_date: today,
        pickup_time: nil,
        pickup_name: "",
        pickup_phone: "",
        special_instructions: "",
        order_items: []
      })

    socket =
      socket
      |> assign(:restaurant, restaurant)
      |> assign(:menu_items, Enum.group_by(menu_items, & &1.category))
      |> assign(:cart, %{})
      |> assign(:total_amount, Decimal.new(0))
      |> assign(:available_hours, available_hours)
      |> assign(:form, Phoenix.Component.to_form(changeset))
      |> assign(:page_title, "Pedido para llevar - #{restaurant.name}")

    {:ok, socket}
  end

  @impl true
  def handle_event("add_to_cart", %{"id" => id}, socket) do
    menu_item =
      Enum.find(
        List.flatten(Map.values(socket.assigns.menu_items)),
        &(&1.id == String.to_integer(id))
      )

    cart = socket.assigns.cart

    updated_cart =
      Map.update(
        cart,
        menu_item.id,
        %{item: menu_item, quantity: 1},
        fn item_data ->
          %{item: item_data.item, quantity: item_data.quantity + 1}
        end
      )

    new_total = calculate_total(updated_cart)

    {:noreply,
     socket
     |> assign(:cart, updated_cart)
     |> assign(:total_amount, new_total)}
  end

  def handle_event("remove_from_cart", %{"id" => id}, socket) do
    id = String.to_integer(id)
    cart = socket.assigns.cart

    updated_cart =
      if cart[id].quantity > 1 do
        Map.update!(
          cart,
          id,
          fn item_data ->
            %{item: item_data.item, quantity: item_data.quantity - 1}
          end
        )
      else
        Map.delete(cart, id)
      end

    new_total = calculate_total(updated_cart)

    {:noreply,
     socket
     |> assign(:cart, updated_cart)
     |> assign(:total_amount, new_total)}
  end

  def handle_event("save", %{"order" => order_params}, socket) do
    cart = socket.assigns.cart
    restaurant = socket.assigns.restaurant
    current_scope = socket.assigns.current_scope

    if map_size(cart) == 0 do
      {:noreply, put_flash(socket, :error, "Debes agregar al menos un producto al carrito")}
    else
      order_items =
        Enum.map(cart, fn {_id, %{item: item, quantity: quantity}} ->
          %{
            menu_item_id: item.id,
            quantity: quantity,
            price: item.price
          }
        end)

      today = local_today()

      params =
        order_params
        |> Map.put("order_items", order_items)
        |> Map.put("order_type", "pickup")
        |> Map.put("status", "pending")
        |> Map.put("total_amount", socket.assigns.total_amount)
        |> Map.put("pickup_date", today)
        |> Map.put("user_id", current_scope.user.id)

      params = update_pickup_time(params)

      case Orders.create_pickup_order(current_scope, restaurant.id, params) do
        {:ok, _order} ->
          {:noreply,
           socket
           |> put_flash(:info, "Pedido realizado con éxito")
           |> push_navigate(to: ~p"/restaurants/#{restaurant}")}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply,
           socket
           |> assign(:form, Phoenix.Component.to_form(changeset))
           |> put_flash(:error, "Error al crear el pedido. Por favor verifica los datos.")}
      end
    end
  end

  defp update_pickup_time(%{"pickup_time" => pickup_time} = params) when pickup_time != "" do
    [hours, minutes] = String.split(pickup_time, ":")
    hours_int = String.to_integer(hours)
    minutes_int = String.to_integer(minutes)

    pickup_time = Time.new!(hours_int, minutes_int, 0)
    Map.put(params, "pickup_time", pickup_time)
  end

  defp update_pickup_time(params), do: params

  defp calculate_total(cart) do
    Enum.reduce(cart, Decimal.new(0), fn {_id, %{item: item, quantity: quantity}}, acc ->
      item_total = Decimal.mult(item.price, quantity)
      Decimal.add(acc, item_total)
    end)
  end

  defp round_to_next_half_hour(minute) when minute >= 30, do: 0
  defp round_to_next_half_hour(_minute), do: 30

  defp generate_available_times(start_time, end_time) do
    if Time.compare(start_time, end_time) != :gt do
      next_time = Time.add(start_time, 30 * 60)
      [start_time | generate_available_times(next_time, end_time)]
    else
      []
    end
  end

  defp local_today() do
    utc_datetime = DateTime.utc_now()
    local_datetime = DateTime.add(utc_datetime, -6 * 60 * 60, :second)
    DateTime.to_date(local_datetime)
  end

  defp local_time() do
    utc_datetime = DateTime.utc_now()
    local_datetime = DateTime.add(utc_datetime, -6 * 60 * 60, :second)
    DateTime.to_time(local_datetime)
  end

  defp time_to_string(time) do
    "#{String.pad_leading("#{time.hour}", 2, "0")}:#{String.pad_leading("#{time.minute}", 2, "0")}"
  end
end
