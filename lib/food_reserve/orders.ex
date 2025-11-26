defmodule FoodReserve.Orders do
  @moduledoc """
  El contexto para las ordenes de comida pre-ordenadas.
  """

  import Ecto.Query, warn: false
  alias FoodReserve.Repo

  alias FoodReserve.Orders.Order
  alias FoodReserve.Orders.OrderItem
  alias FoodReserve.Menus.MenuItem
  alias FoodReserve.Notifications
  alias FoodReserve.Reservations.Reservation

  @doc """
  Gets a single order.

  Raises `Ecto.NoResultsError` if the Order does not exist.

  ## Examples

      iex> get_order!(123)
      %Order{}

      iex> get_order!(456)
      ** (Ecto.NoResultsError)

  """
  def get_order!(id) do
    Order
    |> Repo.get!(id)
    |> Repo.preload([:reservation, :restaurant, order_items: [:menu_item]])
  end

  @doc """
  Gets a single order.

  Returns nil if the Order does not exist.

  ## Examples

      iex> get_order(123)
      %Order{}

      iex> get_order(456)
      nil

  """
  def get_order(id) do
    Repo.get(Order, id)
    |> case do
      nil -> nil
      order -> Repo.preload(order, [:reservation, :restaurant, order_items: [:menu_item]])
    end
  end

  @doc """
  Returns the list of orders.

  ## Examples

      iex> list_orders()
      [%Order{}, ...]

  """
  def list_orders do
    Repo.all(Order)
    |> Repo.preload([:reservation, order_items: [:menu_item]])
  end

  @doc """
  Returns the list of orders for a specific user.

  ## Examples

      iex> list_user_orders(%FoodReserve.Accounts.Scope{user: %User{id: 123}})
      [%Order{}, ...]

  """
  def list_user_orders(%FoodReserve.Accounts.Scope{user: user}) do
    user_id = user.id

    # Consulta para obtener pedidos donde el user_id coincide
    query =
      from o in Order,
        where: o.user_id == ^user_id,
        order_by: [desc: o.inserted_at],
        preload: [:restaurant, order_items: [:menu_item]]

    Repo.all(query)
  end

  @doc """
  Devuelve la lista de pedidos para los restaurantes del dueño.
  """
  def list_restaurant_owner_orders(%FoodReserve.Accounts.Scope{} = scope) do
    # Verificar que el usuario es dueño de restaurante
    if scope.user.role != "restaurant_owner" do
      raise "Solo los dueños de restaurantes pueden ver sus pedidos"
    end

    # Obtener los IDs de los restaurantes del dueño
    restaurant_ids =
      FoodReserve.Restaurants.list_restaurants(scope)
      |> Enum.map(& &1.id)

    # Necesitamos dos consultas separadas y luego combinarlas:
    # 1. Pedidos asociados a reservaciones (dine_in)
    dine_in_orders =
      Order
      |> join(:inner, [o], r in assoc(o, :reservation))
      |> where([o, r], r.restaurant_id in ^restaurant_ids)
      |> order_by([o], desc: o.inserted_at)
      |> preload([o], [:reservation, order_items: [:menu_item]])
      |> Repo.all()

    # 2. Pedidos para llevar (pickup) - estos tienen restaurant_id directamente
    pickup_orders =
      Order
      |> where([o], o.restaurant_id in ^restaurant_ids and o.order_type == "pickup")
      |> order_by([o], desc: o.inserted_at)
      |> preload([o], [:restaurant, order_items: [:menu_item]])
      |> Repo.all()

    # Combinar ambas listas y ordenar por fecha de creación (más reciente primero)
    (dine_in_orders ++ pickup_orders)
    |> Enum.sort_by(& &1.inserted_at, fn a, b ->
      case NaiveDateTime.compare(a, b) do
        :gt -> true
        _ -> false
      end
    end)
  end

  # Esta función se ha eliminado para evitar duplicados con get_order!/1 definida anteriormente

  @doc """
  Obtiene un pedido por su ID de reservación.
  """
  def get_order_by_reservation(reservation_id) do
    Order
    |> where([o], o.reservation_id == ^reservation_id)
    |> Repo.one()
    |> Repo.preload([:reservation, order_items: [:menu_item]])
  end

  @doc """
  Crea un pedido con sus ítems.
  """
  def create_order(attrs \\ %{}, items \\ []) do
    # Obtener los ítems del menú para todos los casos
    menu_items =
      Repo.all(from mi in MenuItem, where: mi.id in ^Enum.map(items, & &1.menu_item_id))

    menu_items_map = Enum.reduce(menu_items, %{}, fn mi, acc -> Map.put(acc, mi.id, mi) end)

    # Verificar si ya viene el total en attrs
    attrs =
      if Map.has_key?(attrs, "total_amount") || Map.has_key?(attrs, :total_amount) do
        # Ya viene el total, dejamos attrs intacto
        attrs
      else
        # Calcular el total basado en los ítems del pedido
        total_amount =
          Enum.reduce(items, Decimal.new(0), fn item, acc ->
            item_price = menu_items_map[item.menu_item_id].price
            item_total = Decimal.mult(item_price, Decimal.new(item.quantity))
            Decimal.add(acc, item_total)
          end)

        # Agregar el total calculado a los attrs
        Map.put(attrs, "total_amount", total_amount)
      end

    Repo.transaction(fn ->
      # Crear el pedido
      {:ok, order} =
        %Order{}
        |> Order.changeset(attrs)
        |> Repo.insert()

      # Crear los ítems del pedido
      items_with_order_id =
        Enum.map(items, fn item ->
          menu_item = menu_items_map[item.menu_item_id]

          item
          |> Map.put(:order_id, order.id)
          |> Map.put_new(:price, menu_item.price)
        end)

      results =
        Enum.map(items_with_order_id, fn item ->
          %OrderItem{}
          |> OrderItem.changeset(item)
          |> Repo.insert()
        end)

      # Verificar si todos los ítems se insertaron correctamente
      if Enum.any?(results, fn {status, _} -> status != :ok end) do
        Repo.rollback(:error_creating_items)
      else
        # Si la reservación tiene un dueño de restaurante, notificarle del nuevo pedido
        if attrs[:reservation_id] do
          notify_new_order(order.id)
        end

        order = order |> Repo.preload([:reservation, order_items: [:menu_item]])
        order
      end
    end)
  end

  @doc """
  Actualiza un pedido.
  """
  def update_order(%Order{} = order, attrs) do
    order
    |> Order.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Elimina un pedido.
  """
  def delete_order(%Order{} = order) do
    Repo.delete(order)
  end

  @doc """
  Cambia el estado de un pedido.
  """
  def update_order_status(%Order{} = order, new_status) do
    changeset = Order.changeset(order, %{status: new_status})

    case Repo.update(changeset) do
      {:ok, updated_order} ->
        # Precargar relaciones necesarias según el tipo de pedido
        updated_order =
          case updated_order.order_type do
            "dine_in" ->
              updated_order |> Repo.preload(reservation: :restaurant)

            "pickup" ->
              updated_order |> Repo.preload(:restaurant)

            _ ->
              updated_order |> Repo.preload([:restaurant, reservation: :restaurant])
          end

        # Notify user about the status update
        notify_order_status_update(updated_order)
        {:ok, updated_order}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Devuelve un changeset para un pedido.
  """
  def change_order(%Order{} = order, attrs \\ %{}) do
    Order.changeset(order, attrs)
  end

  @doc """
  Updates a pickup order with new information.

  ## Examples

      iex> update_pickup_order(order, %{pickup_time: ~T[14:30:00]})
      {:ok, %Order{}}

  """
  def update_pickup_order(%Order{} = order, attrs) do
    # Solo se permite actualizar pedidos pendientes
    if order.status != "pending" do
      {:error, :not_editable}
    else
      # Crear changeset con los nuevos datos
      changeset = Order.changeset(order, attrs)

      # Actualizar el pedido en una transacción
      Repo.transaction(fn ->
        case Repo.update(changeset) do
          {:ok, updated_order} ->
            # Recuperar el pedido actualizado con sus relaciones
            updated_order = Repo.preload(updated_order, [:restaurant, order_items: [:menu_item]])
            updated_order

          {:error, changeset} ->
            Repo.rollback(changeset)
        end
      end)
    end
  end

  @doc """
  Crea un pedido para llevar sin reservación.

  ## Examples

      iex> create_pickup_order(scope, restaurant_id, %{field: value})
      {:ok, %Order{}}

      iex> create_pickup_order(scope, restaurant_id, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_pickup_order(%FoodReserve.Accounts.Scope{} = _scope, restaurant_id, attrs) do
    # Transacción para crear el pedido y sus elementos
    order_items_params = attrs["order_items"] || []
    attrs = Map.delete(attrs, "order_items")

    # Asegurar que esté asociado al restaurante
    restaurant = FoodReserve.Restaurants.get_restaurant!(restaurant_id)

    # Añadir el restaurante_id al pedido
    attrs = Map.put(attrs, "restaurant_id", restaurant_id)

    # Verificar que el restaurante existe y está activo
    if restaurant do
      Repo.transaction(fn ->
        # Crear el pedido con la asociación al restaurante
        order_changeset = Order.changeset(%Order{}, attrs)

        case Repo.insert(order_changeset) do
          {:ok, order} ->
            # Insertar los elementos del pedido
            _order_items = create_order_items(order.id, order_items_params)

            # Recuperar el pedido con los elementos asociados
            order =
              order
              |> Repo.preload(order_items: [:menu_item])

            # Notificar al dueño del restaurante sobre el nuevo pedido para llevar
            notify_new_pickup_order(order, restaurant_id)

            order

          {:error, changeset} ->
            Repo.rollback(changeset)
        end
      end)
    else
      {:error, :restaurant_not_found}
    end
  end

  defp create_order_items(order_id, items_params) do
    Enum.map(items_params, fn item_params ->
      # Convertir todas las claves a string para evitar mezclas
      string_params =
        for {key, val} <- item_params, into: %{} do
          {to_string(key), val}
        end

      # Asociar el item con el pedido
      item_params = Map.put(string_params, "order_id", order_id)

      # Crear el changeset e insertar
      %OrderItem{}
      |> OrderItem.changeset(item_params)
      |> Repo.insert!()
    end)
  end

  defp notify_new_pickup_order(order, restaurant_id) do
    # Obtener el restaurante
    restaurant = FoodReserve.Restaurants.get_restaurant!(restaurant_id)

    # Crear notificación para el dueño del restaurante
    attrs = %{
      title: "Nuevo pedido para llevar",
      message:
        "Has recibido un nuevo pedido para llevar para hoy #{format_date(order.pickup_date)} a las #{format_time(order.pickup_time)}.",
      type: "pickup_order_created",
      user_id: restaurant.user_id,
      restaurant_id: restaurant.id,
      read: false
    }

    Notifications.create_notification(attrs)
  end

  defp format_time(time) do
    "#{String.pad_leading("#{time.hour}", 2, "0")}:#{String.pad_leading("#{time.minute}", 2, "0")}"
  end

  # Notificaciones

  defp notify_new_order(order_id) do
    order = get_order!(order_id)

    if order.reservation && order.reservation.restaurant do
      user = order.reservation.restaurant.user

      attrs = %{
        title: "Nuevo pedido para reservación",
        message:
          "Se ha creado un nuevo pedido para la reservación a nombre de #{order.reservation.name} el #{format_date(order.reservation.date)}",
        type: "order_created",
        user_id: user.id,
        restaurant_id: order.reservation.restaurant_id,
        reservation_id: order.reservation.id,
        read: false
      }

      Notifications.create_notification(attrs)
    end
  end

  defp notify_order_status_update(%Order{} = order) do
    status_message =
      case order.status do
        "confirmed" -> "confirmado"
        "preparing" -> "en preparación"
        "ready" -> "listo para servir"
        "completed" -> "completado"
        "cancelled" -> "cancelado"
        _ -> order.status
      end

    case order.order_type do
      "dine_in" ->
        notify_dine_in_order_status_update(order, status_message)

      "pickup" ->
        notify_pickup_order_status_update(order, status_message)

      _ ->
        # Tipo de pedido desconocido, no enviamos notificación
        nil
    end
  end

  defp notify_dine_in_order_status_update(
         %Order{reservation_id: reservation_id} = _order,
         status_message
       ) do
    # Obtener la reservación directamente sin usar get_reservation!/2 que requiere un scope
    reservation = Repo.get(Reservation, reservation_id) |> Repo.preload([:restaurant])

    if reservation do
      formatted_time = format_time(reservation.reservation_time)

      attrs = %{
        title: "Actualización de pedido para reservación",
        message:
          "Su pedido para la reservación del #{format_date(reservation.reservation_date)} a las #{formatted_time} ha sido actualizado a: #{status_message}",
        type: "order_updated",
        user_id: reservation.user_id,
        restaurant_id: reservation.restaurant_id,
        reservation_id: reservation.id,
        read: false
      }

      Notifications.create_notification(attrs)
    end
  end

  defp format_date(date) do
    "#{date.day}/#{date.month}/#{date.year}"
  end

  defp notify_pickup_order_status_update(%Order{} = order, status_message) do
    # Para pedidos pickup, notificamos al usuario que hizo el pedido
    formatted_time = format_time(order.pickup_time)

    # Obtener el restaurante
    restaurant = Repo.get!(FoodReserve.Restaurants.Restaurant, order.restaurant_id)

    # Crear notificación para el dueño del restaurante
    attrs = %{
      title: "Actualización de pedido para llevar",
      message:
        "El pedido para llevar del #{format_date(order.pickup_date)} a las #{formatted_time} ha sido actualizado a: #{status_message}",
      type: "pickup_order_updated",
      # Notificamos al dueño del restaurante
      user_id: restaurant.user_id,
      restaurant_id: order.restaurant_id,
      read: false
    }

    Notifications.create_notification(attrs)

    # Si tenemos el pickup_name y pickup_phone, podríamos enviar un SMS o email
    # Pero como simplificación, solo notificamos al dueño del restaurante
  end
end
