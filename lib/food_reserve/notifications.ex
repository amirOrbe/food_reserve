defmodule FoodReserve.Notifications do
  @moduledoc """
  The Notifications context.
  """

  import Ecto.Query, warn: false
  alias FoodReserve.Repo
  alias FoodReserve.Notifications.Notification
  alias FoodReserve.Accounts.Scope

  @doc """
  Returns the list of notifications for a user.

  ## Examples

      iex> list_user_notifications(scope)
      [%Notification{}, ...]

  """
  def list_user_notifications(%Scope{} = scope, opts \\ []) do
    limit = Keyword.get(opts, :limit, 50)

    from(n in Notification,
      where: n.user_id == ^scope.user.id,
      preload: [:restaurant, :reservation],
      order_by: [desc: n.inserted_at],
      limit: ^limit
    )
    |> Repo.all()
  end

  @doc """
  Returns the list of unread notifications for a user.

  ## Examples

      iex> list_unread_notifications(scope)
      [%Notification{}, ...]

  """
  def list_unread_notifications(%Scope{} = scope) do
    from(n in Notification,
      where: n.user_id == ^scope.user.id,
      where: n.read == false,
      preload: [:restaurant, :reservation],
      order_by: [desc: n.inserted_at]
    )
    |> Repo.all()
  end

  @doc """
  Gets the count of unread notifications for a user.

  ## Examples

      iex> count_unread_notifications(scope)
      5

  """
  def count_unread_notifications(%Scope{} = scope) do
    from(n in Notification,
      where: n.user_id == ^scope.user.id,
      where: n.read == false,
      select: count(n.id)
    )
    |> Repo.one()
  end

  @doc """
  Gets a single notification.

  Raises `Ecto.NoResultsError` if the Notification does not exist.

  ## Examples

      iex> get_notification!(123)
      %Notification{}

      iex> get_notification!(456)
      ** (Ecto.NoResultsError)

  """
  def get_notification!(id), do: Repo.get!(Notification, id)

  @doc """
  Gets a notification that belongs to the user.

  ## Examples

      iex> get_user_notification(scope, 123)
      %Notification{}

      iex> get_user_notification(scope, 456)
      nil

  """
  def get_user_notification(%Scope{} = scope, id) do
    from(n in Notification,
      where: n.id == ^id,
      where: n.user_id == ^scope.user.id,
      preload: [:restaurant, :reservation]
    )
    |> Repo.one()
  end

  @doc """
  Creates a notification.

  ## Examples

      iex> create_notification(%{field: value})
      {:ok, %Notification{}}

      iex> create_notification(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_notification(attrs \\ %{}) do
    %Notification{}
    |> Notification.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a notification.

  ## Examples

      iex> update_notification(notification, %{field: new_value})
      {:ok, %Notification{}}

      iex> update_notification(notification, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_notification(%Notification{} = notification, attrs) do
    notification
    |> Notification.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Marks a notification as read.

  ## Examples

      iex> mark_as_read(scope, notification_id)
      {:ok, %Notification{}}

  """
  def mark_as_read(%Scope{} = scope, notification_id) do
    case get_user_notification(scope, notification_id) do
      nil -> {:error, :not_found}
      notification -> update_notification(notification, %{read: true})
    end
  end

  @doc """
  Marks all notifications as read for a user.

  ## Examples

      iex> mark_all_as_read(scope)
      {5, nil}

  """
  def mark_all_as_read(%Scope{} = scope) do
    from(n in Notification,
      where: n.user_id == ^scope.user.id,
      where: n.read == false
    )
    |> Repo.update_all(set: [read: true, updated_at: DateTime.utc_now()])
  end

  @doc """
  Deletes a notification.

  ## Examples

      iex> delete_notification(notification)
      {:ok, %Notification{}}

      iex> delete_notification(notification)
      {:error, %Ecto.Changeset{}}

  """
  def delete_notification(%Notification{} = notification) do
    Repo.delete(notification)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking notification changes.

  ## Examples

      iex> change_notification(notification)
      %Ecto.Changeset{data: %Notification{}}

  """
  def change_notification(%Notification{} = notification, attrs \\ %{}) do
    Notification.changeset(notification, attrs)
  end

  # Funciones específicas para crear notificaciones automáticas

  @doc """
  Crea una notificación cuando se hace una nueva reserva.
  Notifica al dueño del restaurante.
  """
  def notify_new_reservation(reservation) do
    # Precargar datos necesarios
    reservation = Repo.preload(reservation, [:user, restaurant: [:user]])

    create_notification(%{
      title: "Nueva Reserva",
      message:
        "#{reservation.user.name} ha hecho una reserva para #{reservation.party_size} personas el #{Calendar.strftime(reservation.reservation_date, "%d/%m/%Y")} a las #{Calendar.strftime(reservation.reservation_time, "%H:%M")}.",
      type: "reservation_created",
      user_id: reservation.restaurant.user.id,
      restaurant_id: reservation.restaurant_id,
      reservation_id: reservation.id
    })
  end

  @doc """
  Crea una notificación cuando se confirma una reserva.
  Notifica al cliente.
  """
  def notify_reservation_confirmed(reservation) do
    # Precargar datos necesarios
    reservation = Repo.preload(reservation, [:restaurant])

    create_notification(%{
      title: "Reserva Confirmada",
      message:
        "Tu reserva en #{reservation.restaurant.name} para el #{Calendar.strftime(reservation.reservation_date, "%d/%m/%Y")} a las #{Calendar.strftime(reservation.reservation_time, "%H:%M")} ha sido confirmada.",
      type: "reservation_confirmed",
      user_id: reservation.user_id,
      restaurant_id: reservation.restaurant_id,
      reservation_id: reservation.id
    })
  end

  @doc """
  Crea una notificación cuando se declina una reserva.
  Notifica al cliente.
  """
  def notify_reservation_declined(reservation) do
    # Precargar datos necesarios
    reservation = Repo.preload(reservation, [:restaurant])

    create_notification(%{
      title: "Reserva Declinada",
      message:
        "Lamentablemente tu reserva en #{reservation.restaurant.name} para el #{Calendar.strftime(reservation.reservation_date, "%d/%m/%Y")} a las #{Calendar.strftime(reservation.reservation_time, "%H:%M")} ha sido declinada.",
      type: "reservation_declined",
      user_id: reservation.user_id,
      restaurant_id: reservation.restaurant_id,
      reservation_id: reservation.id
    })
  end

  @doc """
  Crea una notificación recordando al cliente que puede dejar una reseña.
  Se envía después de que la fecha de la reserva haya pasado.
  """
  def notify_review_reminder(reservation) do
    # Precargar datos necesarios
    reservation = Repo.preload(reservation, [:restaurant])

    create_notification(%{
      title: "¿Cómo estuvo tu experiencia?",
      message:
        "Esperamos que hayas disfrutado tu visita a #{reservation.restaurant.name}. ¡Comparte tu experiencia y ayuda a otros comensales!",
      type: "review_reminder",
      user_id: reservation.user_id,
      restaurant_id: reservation.restaurant_id,
      reservation_id: reservation.id
    })
  end
end
