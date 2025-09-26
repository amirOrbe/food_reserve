defmodule FoodReserve.Restaurants do
  @moduledoc """
  The Restaurants context.
  """

  import Ecto.Query, warn: false
  alias FoodReserve.Repo

  alias FoodReserve.Restaurants.Restaurant
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

end
