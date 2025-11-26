defmodule FoodReserve.Reservations do
  @moduledoc """
  The Reservations context.
  """

  import Ecto.Query, warn: false
  alias FoodReserve.Repo
  alias FoodReserve.Reservations.Reservation
  alias FoodReserve.Restaurants
  alias FoodReserve.Accounts.Scope
  alias FoodReserve.Notifications

  @doc """
  Subscribes to scoped notifications about any reservation changes.

  The broadcasted messages match the pattern:

    * {:created, %Reservation{}}
    * {:updated, %Reservation{}}
    * {:deleted, %Reservation{}}

  """
  def subscribe_reservations(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(FoodReserve.PubSub, "user:#{key}:reservations")
  end

  defp broadcast_reservation(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(FoodReserve.PubSub, "user:#{key}:reservations", message)
  end

  @doc """
  Returns the list of reservations.

  ## Examples

      iex> list_reservations(scope)
      [%Reservation{}, ...]

  """
  def list_reservations(%Scope{} = scope) do
    Repo.all_by(Reservation, user_id: scope.user.id)
  end

  @doc """
  Gets a single reservation.

  Raises `Ecto.NoResultsError` if the Reservation does not exist.

  ## Examples

      iex> get_reservation!(scope, 123)
      %Reservation{}

      iex> get_reservation!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_reservation!(%Scope{} = scope, id, preloads \\ [:restaurant]) do
    Repo.get_by!(Reservation, id: id, user_id: scope.user.id)
    |> Repo.preload(preloads)
  end

  @doc """
  Creates a reservation.

  ## Examples

      iex> create_reservation(scope, %{field: value})
      {:ok, %Reservation{}}

      iex> create_reservation(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_reservation(%Scope{} = scope, attrs) do
    with {:ok, reservation = %Reservation{}} <-
           %Reservation{}
           |> Reservation.changeset(attrs)
           |> Repo.insert() do
      broadcast_reservation(scope, {:created, reservation})

      # Crear notificación para el dueño del restaurante
      Task.start(fn ->
        Notifications.notify_new_reservation(reservation)
      end)

      {:ok, reservation}
    end
  end

  @doc """
  Updates a reservation.

  ## Examples

      iex> update_reservation(scope, reservation, %{field: new_value})
      {:ok, %Reservation{}}

      iex> update_reservation(scope, reservation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_reservation(%Scope{} = scope, %Reservation{} = reservation, attrs) do
    IO.puts("[update_reservation] Initial attrs: #{inspect(attrs)}")

    # Verify user_id matches scope
    true = reservation.user_id == scope.user.id

    # Create changeset for debugging
    changeset = Reservation.changeset(reservation, attrs)
    IO.puts("[update_reservation] Changeset valid? #{changeset.valid?}")

    if !changeset.valid? do
      IO.puts("[update_reservation] Changeset errors: #{inspect(changeset.errors)}")
    end

    # Try to update
    with {:ok, reservation = %Reservation{}} <-
           Repo.update(changeset) do
      broadcast_reservation(scope, {:updated, reservation})
      IO.puts("[update_reservation] Success! New party_size: #{reservation.party_size}")
      {:ok, reservation}
    else
      {:error, changeset} = error ->
        IO.puts("[update_reservation] Error: #{inspect(changeset.errors)}")
        error
    end
  end

  @doc """
  Deletes a reservation.

  ## Examples

      iex> delete_reservation(scope, reservation)
      {:ok, %Reservation{}}

      iex> delete_reservation(scope, reservation)
      {:error, %Ecto.Changeset{}}

  """
  def delete_reservation(%Scope{} = scope, %Reservation{} = reservation) do
    true = reservation.user_id == scope.user.id

    with {:ok, reservation = %Reservation{}} <-
           Repo.delete(reservation) do
      broadcast_reservation(scope, {:deleted, reservation})
      {:ok, reservation}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking reservation changes.

  ## Examples

      iex> change_reservation(scope, reservation)
      %Ecto.Changeset{data: %Reservation{}}

  """
  def change_reservation(%Scope{} = scope, %Reservation{} = reservation, attrs \\ %{}) do
    true = reservation.user_id == scope.user.id

    Reservation.changeset(reservation, attrs)
  end

  @doc """
  Updates the status of a reservation.

  ## Examples

      iex> update_reservation_status(reservation, "confirmed")
      {:ok, %Reservation{}}

      iex> update_reservation_status(reservation, "invalid_status")
      {:error, %Ecto.Changeset{}}
  """
  def update_reservation_status(%Reservation{} = reservation, status)
      when status in ["pending", "confirmed", "cancelled", "completed"] do
    reservation
    |> Reservation.changeset(%{"status" => status})
    |> Repo.update()
  end

  @doc """
  Marks a reservation as cancelled.
  """
  def cancel_reservation(reservation_id, user_scope \\ nil) do
    # If no scope is provided, get the reservation without validating permissions
    reservation =
      if user_scope do
        get_reservation!(user_scope, reservation_id)
      else
        # Get directly without permission validation
        Repo.get!(Reservation, reservation_id)
      end

    update_reservation_status(reservation, "cancelled")
  end

  @doc """
  Marks a reservation as completed and sends notification to review the restaurant.
  """
  def complete_reservation_and_notify(reservation_id) do
    # Get directly from repo to avoid permission validation
    reservation = Repo.get!(Reservation, reservation_id) |> Repo.preload([:restaurant])

    with {:ok, updated_reservation} <- update_reservation_status(reservation, "completed") do
      # Send review reminder notification
      Task.start(fn ->
        FoodReserve.Notifications.notify_review_reminder(updated_reservation)
      end)

      {:ok, updated_reservation}
    end
  end

  @doc """
  Gets reservations that should be marked as completed.

  A reservation is considered ready to be marked as completed if:
  1. Its status is "confirmed"
  2. Its date is in the past, or
  3. Its date is today and its time + threshold_hours is in the past

  ## Examples

      iex> get_reservations_to_complete(today, now, 2)
      [%Reservation{}, ...]
  """
  def get_reservations_to_complete(today, now, threshold_hours) do
    past_time_threshold = Time.add(now, -threshold_hours * 60 * 60)

    from(r in Reservation,
      where: r.status == "confirmed",
      where:
        r.reservation_date < ^today or
          (r.reservation_date == ^today and r.reservation_time < ^past_time_threshold),
      preload: [:restaurant]
    )
    |> Repo.all()
  end

  @doc """
  Returns the list of existing reservations for a specific restaurant and date.

  ## Examples

      iex> get_existing_reservations(restaurant_id, date)
      [%Reservation{}, ...]
  """
  def get_existing_reservations(restaurant_id, date) do
    from(r in Reservation,
      where: r.restaurant_id == ^restaurant_id,
      where: r.reservation_date == ^date,
      where: r.status in ["pending", "confirmed"],
      select: r.reservation_time
    )
    |> Repo.all()
  end

  @doc """
  Returns the list of booked times for a specific restaurant and date, excluding a specific reservation.

  ## Examples

      iex> get_booked_times_for_date(date, restaurant_id, reservation_id)
      [~T[18:00:00], ...]
  """
  def get_booked_times_for_date(date, restaurant_id, reservation_id) do
    from(r in Reservation,
      where: r.restaurant_id == ^restaurant_id,
      where: r.reservation_date == ^date,
      where: r.status in ["pending", "confirmed"],
      where: r.id != ^reservation_id,
      select: r.reservation_time
    )
    |> Repo.all()
  end

  @doc """
  Returns restaurants where the user has made reservations with their latest reservation info.

  ## Examples

      iex> get_user_restaurants_with_reservations(scope)
      [%{restaurant: %Restaurant{}, latest_reservation: %Reservation{}, total_reservations: 3}, ...]
  """
  def get_user_restaurants_with_reservations(%Scope{} = scope) do
    # Subconsulta para obtener la reserva más reciente por restaurante
    latest_reservation_subquery =
      from(r in Reservation,
        where: r.user_id == ^scope.user.id,
        group_by: r.restaurant_id,
        select: %{
          restaurant_id: r.restaurant_id,
          latest_id: max(r.id)
        }
      )

    # Consulta principal que obtiene restaurantes con información de reservas
    from(r in Reservation,
      join: lr in subquery(latest_reservation_subquery),
      on: r.id == lr.latest_id,
      join: restaurant in assoc(r, :restaurant),
      where: r.user_id == ^scope.user.id,
      select: %{
        restaurant: restaurant,
        latest_reservation: r,
        total_reservations:
          fragment(
            "(SELECT COUNT(*) FROM reservations WHERE user_id = ? AND restaurant_id = ?)",
            ^scope.user.id,
            r.restaurant_id
          )
      },
      order_by: [desc: r.inserted_at]
    )
    |> Repo.all()
  end

  @doc """
  Returns all reservations for a user.

  ## Examples

      iex> list_user_reservations(scope)
      [%Reservation{}, ...]
  """
  def list_user_reservations(%Scope{} = scope, preloads \\ []) do
    base_preloads = [:restaurant]
    full_preloads = base_preloads ++ preloads

    from(r in Reservation,
      where: r.user_id == ^scope.user.id,
      preload: ^full_preloads,
      order_by: [desc: r.reservation_date, desc: r.reservation_time]
    )
    |> Repo.all()
  end

  @doc """
  Returns reservations for a specific restaurant that the owner can manage.
  Only shows customer name and phone for privacy.

  ## Examples

      iex> list_restaurant_reservations(scope, restaurant_id)
      [%Reservation{}, ...]
  """
  def list_restaurant_reservations(%Scope{} = scope, restaurant_id) do
    # Verificar que el usuario sea dueño del restaurante
    restaurant = Restaurants.get_restaurant!(scope, restaurant_id)
    true = restaurant.user_id == scope.user.id

    from(r in Reservation,
      where: r.restaurant_id == ^restaurant_id,
      order_by: [asc: r.reservation_date, asc: r.reservation_time],
      select: %{
        id: r.id,
        reservation_date: r.reservation_date,
        reservation_time: r.reservation_time,
        party_size: r.party_size,
        customer_name: r.customer_name,
        customer_phone: r.customer_phone,
        status: r.status,
        inserted_at: r.inserted_at
      }
    )
    |> Repo.all()
  end

  @doc """
  Returns only pending reservations for a restaurant.

  ## Examples

      iex> list_pending_restaurant_reservations(scope, restaurant_id)
      [%Reservation{}, ...]
  """
  def list_pending_restaurant_reservations(%Scope{} = scope, restaurant_id) do
    # Verificar que el usuario sea dueño del restaurante
    restaurant = Restaurants.get_restaurant!(scope, restaurant_id)
    true = restaurant.user_id == scope.user.id

    from(r in Reservation,
      where: r.restaurant_id == ^restaurant_id,
      where: r.status == "pending",
      order_by: [asc: r.reservation_date, asc: r.reservation_time],
      select: %{
        id: r.id,
        reservation_date: r.reservation_date,
        reservation_time: r.reservation_time,
        party_size: r.party_size,
        customer_name: r.customer_name,
        customer_phone: r.customer_phone,
        status: r.status,
        inserted_at: r.inserted_at
      }
    )
    |> Repo.all()
  end

  @doc """
  Confirms a reservation (restaurant owner action).

  ## Examples

      iex> confirm_reservation(scope, reservation_id)
      {:ok, %Reservation{}}
  """
  def confirm_reservation(%Scope{} = scope, reservation_id) do
    # Obtener la reserva completa para verificar permisos y enviar notificación
    case from(r in Reservation,
           join: restaurant in assoc(r, :restaurant),
           where: r.id == ^reservation_id,
           where: restaurant.user_id == ^scope.user.id,
           preload: [:restaurant]
         )
         |> Repo.one() do
      nil ->
        {:error, :not_found}

      reservation ->
        # Actualizar directamente el estado sin validaciones adicionales
        case Repo.update(Ecto.Changeset.change(reservation, status: "confirmed")) do
          {:ok, updated_reservation} ->
            # Crear notificación para el cliente
            Task.start(fn ->
              Notifications.notify_reservation_confirmed(updated_reservation)
            end)

            {:ok, :updated}

          {:error, changeset} ->
            {:error, changeset}
        end
    end
  end

  @doc """
  Declines a reservation (restaurant owner action).

  ## Examples

      iex> decline_reservation(scope, reservation_id)
      {:ok, %Reservation{}}
  """
  def decline_reservation(%Scope{} = scope, reservation_id) do
    # Obtener la reserva completa para verificar permisos y enviar notificación
    case from(r in Reservation,
           join: restaurant in assoc(r, :restaurant),
           where: r.id == ^reservation_id,
           where: restaurant.user_id == ^scope.user.id,
           preload: [:restaurant]
         )
         |> Repo.one() do
      nil ->
        {:error, :not_found}

      reservation ->
        # Actualizar directamente el estado sin validaciones adicionales
        case Repo.update(Ecto.Changeset.change(reservation, status: "cancelled")) do
          {:ok, updated_reservation} ->
            # Crear notificación para el cliente
            Task.start(fn ->
              Notifications.notify_reservation_declined(updated_reservation)
            end)

            {:ok, :updated}

          {:error, changeset} ->
            {:error, changeset}
        end
    end
  end
end
