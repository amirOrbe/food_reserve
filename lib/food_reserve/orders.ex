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

  @doc """
  Devuelve la lista de pedidos.
  """
  def list_orders do
    Repo.all(Order)
    |> Repo.preload([:reservation, order_items: [:menu_item]])
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

    # Obtener pedidos para estos restaurantes
    Order
    |> join(:inner, [o], r in assoc(o, :reservation))
    |> where([o, r], r.restaurant_id in ^restaurant_ids)
    |> order_by([o], desc: o.inserted_at)
    |> preload([o], [:reservation, order_items: [:menu_item]])
    |> Repo.all()
  end

  @doc """
  Obtiene un solo pedido.
  """
  def get_order!(id) do
    Order
    |> Repo.get!(id)
    |> Repo.preload([:reservation, order_items: [:menu_item]])
  end

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
  def update_order_status(%Order{} = order, status) do
    order
    |> Order.changeset(%{status: status})
    |> Repo.update()
    |> case do
      {:ok, updated_order} ->
        # Notificar al cliente sobre el cambio de estado
        notify_order_status_update(updated_order)
        {:ok, updated_order}

      error ->
        error
    end
  end

  @doc """
  Devuelve un changeset para un pedido.
  """
  def change_order(%Order{} = order, attrs \\ %{}) do
    Order.changeset(order, attrs)
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
    reservation = order.reservation

    if reservation && reservation.user_id do
      status_message =
        case order.status do
          "confirmed" -> "confirmado"
          "preparing" -> "en preparación"
          "ready" -> "listo para servir"
          "completed" -> "completado"
          "cancelled" -> "cancelado"
          _ -> order.status
        end

      formatted_time =
        "#{reservation.reservation_time.hour}:#{String.pad_leading("#{reservation.reservation_time.minute}", 2, "0")}"

      attrs = %{
        title: "Actualización de pedido",
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
end
