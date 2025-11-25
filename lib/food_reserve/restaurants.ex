defmodule FoodReserve.Restaurants do
  @moduledoc """
  The Restaurants context.
  """

  import Ecto.Query, warn: false
  alias FoodReserve.Repo

  alias FoodReserve.Restaurants.Restaurant
  alias FoodReserve.Restaurants.WorkingHour
  alias FoodReserve.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any restaurant changes.

  The broadcasted messages match the pattern:

    * {:created, %Restaurant{}}
    * {:updated, %Restaurant{}}
    * {:deleted, %Restaurant{}}

  """
  def subscribe_restaurants(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(FoodReserve.PubSub, "user:#{key}:restaurants")
  end

  defp broadcast_restaurant(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(FoodReserve.PubSub, "user:#{key}:restaurants", message)
  end

  @doc """
  Returns the list of restaurants.

  ## Examples

      iex> list_restaurants(scope)
      [%Restaurant{}, ...]

  """
  def list_restaurants(%Scope{} = scope) do
    Repo.all_by(Restaurant, user_id: scope.user.id)
  end

  @doc """
  Returns a list of public restaurants for display on the home page.

  ## Examples

      iex> list_public_restaurants()
      [%Restaurant{}, ...]

      iex> list_public_restaurants(limit: 6)
      [%Restaurant{}, ...]
  """
  def list_public_restaurants(opts \\ []) do
    limit = Keyword.get(opts, :limit, 10)

    Restaurant
    |> order_by([r], desc: r.inserted_at)
    |> limit(^limit)
    |> Repo.all()
  end

  @doc """
  Gets a single restaurant.

  Raises `Ecto.NoResultsError` if the Restaurant does not exist.

  ## Examples

      iex> get_restaurant!(scope, 123)
      %Restaurant{}

      iex> get_restaurant!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_restaurant!(%Scope{} = scope, id) do
    Repo.get_by!(Restaurant, id: id, user_id: scope.user.id)
  end

  @doc """
  Gets a single restaurant by ID for public access.

  Raises `Ecto.NoResultsError` if the Restaurant does not exist.

  ## Examples

      iex> get_public_restaurant!(123)
      %Restaurant{}

      iex> get_public_restaurant!(456)
      ** (Ecto.NoResultsError)
  """
  def get_public_restaurant!(id) do
    Repo.get!(Restaurant, id)
  end

  @doc """
  Creates a restaurant.

  ## Examples

      iex> create_restaurant(scope, %{field: value})
      {:ok, %Restaurant{}}

      iex> create_restaurant(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_restaurant(%Scope{} = scope, attrs) do
    attrs = Map.put(attrs, "user_id", scope.user.id)

    with {:ok, restaurant = %Restaurant{}} <-
           %Restaurant{}
           |> Restaurant.changeset(attrs)
           |> Repo.insert() do
      broadcast_restaurant(scope, {:created, restaurant})
      {:ok, restaurant}
    end
  end

  @doc """
  Updates a restaurant.

  ## Examples

      iex> update_restaurant(scope, restaurant, %{field: new_value})
      {:ok, %Restaurant{}}

      iex> update_restaurant(scope, restaurant, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_restaurant(%Scope{} = scope, %Restaurant{} = restaurant, attrs) do
    true = restaurant.user_id == scope.user.id

    with {:ok, restaurant = %Restaurant{}} <-
           restaurant
           |> Restaurant.changeset(attrs)
           |> Repo.update() do
      broadcast_restaurant(scope, {:updated, restaurant})
      {:ok, restaurant}
    end
  end

  @doc """
  Deletes a restaurant.

  ## Examples

      iex> delete_restaurant(scope, restaurant)
      {:ok, %Restaurant{}}

      iex> delete_restaurant(scope, restaurant)
      {:error, %Ecto.Changeset{}}

  """
  def delete_restaurant(%Scope{} = scope, %Restaurant{} = restaurant) do
    true = restaurant.user_id == scope.user.id

    with {:ok, restaurant = %Restaurant{}} <-
           Repo.delete(restaurant) do
      broadcast_restaurant(scope, {:deleted, restaurant})
      {:ok, restaurant}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking restaurant changes.

  ## Examples

      iex> change_restaurant(scope, restaurant)
      %Ecto.Changeset{data: %Restaurant{}}

  """
  def change_restaurant(%Scope{} = scope, %Restaurant{} = restaurant, attrs \\ %{}) do
    true = restaurant.user_id == scope.user.id

    Restaurant.changeset(restaurant, attrs)
  end

  # Working Hours functions

  @doc """
  Returns the list of all working hours for restaurants owned by the user.

  ## Examples

      iex> list_working_hours(scope)
      [%WorkingHour{}, ...]
  """
  def list_working_hours(%Scope{} = scope) do
    from(wh in WorkingHour,
      join: r in assoc(wh, :restaurant),
      where: r.user_id == ^scope.user.id,
      order_by: [asc: wh.day_of_week]
    )
    |> Repo.all()
  end

  @doc """
  Returns the list of working hours for a restaurant that a user owns.

  ## Examples

      iex> list_working_hours_by_restaurant(scope, restaurant_id)
      [%WorkingHour{}, ...]
  """
  def list_working_hours_by_restaurant(%Scope{} = scope, restaurant_id) do
    from(wh in WorkingHour,
      join: r in assoc(wh, :restaurant),
      where: wh.restaurant_id == ^restaurant_id,
      where: r.user_id == ^scope.user.id,
      order_by: [
        fragment(
          "CASE ?
          WHEN 'monday' THEN 1
          WHEN 'tuesday' THEN 2
          WHEN 'wednesday' THEN 3
          WHEN 'thursday' THEN 4
          WHEN 'friday' THEN 5
          WHEN 'saturday' THEN 6
          WHEN 'sunday' THEN 7
        END",
          wh.day_of_week
        )
      ]
    )
    |> Repo.all()
  end

  @doc """
  Returns the list of working hours for a restaurant (public access).

  ## Examples

      iex> get_public_working_hours(restaurant_id)
      [%WorkingHour{}, ...]
  """
  def get_public_working_hours(restaurant_id) do
    from(wh in WorkingHour,
      where: wh.restaurant_id == ^restaurant_id,
      order_by: [
        fragment(
          "CASE ?
          WHEN 'monday' THEN 1
          WHEN 'tuesday' THEN 2
          WHEN 'wednesday' THEN 3
          WHEN 'thursday' THEN 4
          WHEN 'friday' THEN 5
          WHEN 'saturday' THEN 6
          WHEN 'sunday' THEN 7
        END",
          wh.day_of_week
        )
      ]
    )
    |> Repo.all()
  end

  @doc """
  Creates or updates working hours for a restaurant.

  ## Examples

      iex> upsert_working_hour(scope, restaurant_id, attrs)
      {:ok, %WorkingHour{}}
  """
  def upsert_working_hour(%Scope{} = scope, restaurant_id, attrs) do
    # Verificar que el restaurante pertenece al usuario
    restaurant = get_restaurant!(scope, restaurant_id)

    # Verificar que day_of_week está presente
    day_of_week = attrs["day_of_week"] || Map.get(attrs, :day_of_week)

    if day_of_week == nil do
      # Si day_of_week es nil, devolver error
      changeset =
        %WorkingHour{}
        |> WorkingHour.changeset(Map.put(attrs, "restaurant_id", restaurant.id))

      {:error, changeset}
    else
      attrs = Map.put(attrs, "restaurant_id", restaurant.id)

      case Repo.get_by(WorkingHour, restaurant_id: restaurant.id, day_of_week: day_of_week) do
        nil ->
          %WorkingHour{}
          |> WorkingHour.changeset(attrs)
          |> Repo.insert()

        existing_hour ->
          existing_hour
          |> WorkingHour.changeset(attrs)
          |> Repo.update()
      end
    end
  end

  @doc """
  Gets a single working_hour by id.

  ## Examples

      iex> get_working_hour!(scope, 123)
      %WorkingHour{}

  Raises `Ecto.NoResultsError` if the working hour does not exist or does not belong to user's restaurant.
  """
  def get_working_hour!(%Scope{} = scope, id) do
    from(wh in WorkingHour,
      join: r in assoc(wh, :restaurant),
      where: wh.id == ^id and r.user_id == ^scope.user.id
    )
    |> Repo.one!()
  end

  @doc """
  Deletes a working hour.

  ## Examples

      iex> delete_working_hour(scope, working_hour)
      {:ok, %WorkingHour{}}
  """
  def delete_working_hour(%Scope{} = scope, %WorkingHour{} = working_hour) do
    # Verificar que el horario pertenece a un restaurante del usuario
    _restaurant = get_restaurant!(scope, working_hour.restaurant_id)

    Repo.delete(working_hour)
  end

  @doc """
  Returns a working_hour changeset.

  ## Examples

      iex> change_working_hour(scope, working_hour)
      %Ecto.Changeset{}
  """
  def change_working_hour(%Scope{} = scope, %WorkingHour{} = working_hour, attrs \\ %{}) do
    # Verificar que el horario pertenece a un restaurante del usuario
    _restaurant = get_restaurant!(scope, working_hour.restaurant_id)

    WorkingHour.changeset(working_hour, attrs)
  end
end
