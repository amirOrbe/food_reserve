defmodule FoodReserve.Reviews do
  @moduledoc """
  The Reviews context.
  """

  import Ecto.Query, warn: false
  alias FoodReserve.Repo
  alias FoodReserve.Reviews.Review
  alias FoodReserve.Accounts.Scope

  @doc """
  Returns the list of reviews for a restaurant.

  ## Examples

      iex> list_restaurant_reviews(restaurant_id)
      [%Review{}, ...]

  """
  def list_restaurant_reviews(restaurant_id) do
    from(r in Review,
      where: r.restaurant_id == ^restaurant_id,
      preload: [:user],
      order_by: [desc: r.inserted_at]
    )
    |> Repo.all()
  end

  @doc """
  Returns the list of reviews by a user.

  ## Examples

      iex> list_user_reviews(scope)
      [%Review{}, ...]

  """
  def list_user_reviews(%Scope{} = scope) do
    from(r in Review,
      where: r.user_id == ^scope.user.id,
      preload: [:restaurant],
      order_by: [desc: r.inserted_at]
    )
    |> Repo.all()
  end

  @doc """
  Gets a single review.

  Raises `Ecto.NoResultsError` if the Review does not exist.

  ## Examples

      iex> get_review!(123)
      %Review{}

      iex> get_review!(456)
      ** (Ecto.NoResultsError)

  """
  def get_review!(id), do: Repo.get!(Review, id)

  @doc """
  Gets a review by user and restaurant.

  ## Examples

      iex> get_user_restaurant_review(scope, restaurant_id)
      %Review{}

      iex> get_user_restaurant_review(scope, restaurant_id)
      nil

  """
  def get_user_restaurant_review(%Scope{} = scope, restaurant_id) do
    from(r in Review,
      where: r.user_id == ^scope.user.id,
      where: r.restaurant_id == ^restaurant_id
    )
    |> Repo.one()
  end

  @doc """
  Creates a review.

  ## Examples

      iex> create_review(scope, %{field: value})
      {:ok, %Review{}}

      iex> create_review(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_review(%Scope{} = scope, attrs \\ %{}) do
    attrs = Map.put(attrs, "user_id", scope.user.id)

    %Review{}
    |> Review.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a review.

  ## Examples

      iex> update_review(scope, review, %{field: new_value})
      {:ok, %Review{}}

      iex> update_review(scope, review, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_review(%Scope{} = scope, %Review{} = review, attrs) do
    # Verificar que el usuario sea el dueño de la reseña
    if review.user_id == scope.user.id do
      review
      |> Review.changeset(attrs)
      |> Repo.update()
    else
      {:error, :unauthorized}
    end
  end

  @doc """
  Deletes a review.

  ## Examples

      iex> delete_review(scope, review)
      {:ok, %Review{}}

      iex> delete_review(scope, review)
      {:error, %Ecto.Changeset{}}

  """
  def delete_review(%Scope{} = scope, %Review{} = review) do
    # Verificar que el usuario sea el dueño de la reseña
    if review.user_id == scope.user.id do
      Repo.delete(review)
    else
      {:error, :unauthorized}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking review changes.

  ## Examples

      iex> change_review(review)
      %Ecto.Changeset{data: %Review{}}

  """
  def change_review(%Review{} = review, attrs \\ %{}) do
    Review.changeset(review, attrs)
  end

  @doc """
  Calcula las estadísticas de reseñas para un restaurante.

  ## Examples

      iex> get_restaurant_review_stats(restaurant_id)
      %{
        total_reviews: 10,
        average_food_rating: 4.2,
        average_service_rating: 4.5,
        average_overall_rating: 4.35
      }

  """
  def get_restaurant_review_stats(restaurant_id) do
    query =
      from(r in Review,
        where: r.restaurant_id == ^restaurant_id,
        select: %{
          total_reviews: count(r.id),
          average_food_rating: avg(r.food_rating),
          average_service_rating: avg(r.service_rating)
        }
      )

    case Repo.one(query) do
      %{total_reviews: 0} ->
        %{
          total_reviews: 0,
          average_food_rating: 0.0,
          average_service_rating: 0.0,
          average_overall_rating: 0.0
        }

      %{total_reviews: total, average_food_rating: food, average_service_rating: service} ->
        # Convertir Decimal a float para operaciones aritméticas
        food_float = Decimal.to_float(food)
        service_float = Decimal.to_float(service)
        overall = (food_float + service_float) / 2

        %{
          total_reviews: total,
          average_food_rating: Float.round(food_float, 1),
          average_service_rating: Float.round(service_float, 1),
          average_overall_rating: Float.round(overall, 1)
        }
    end
  end

  @doc """
  Verifica si un usuario puede dejar una reseña para un restaurante.
  Solo puede dejar una reseña si ha tenido una reserva confirmada.

  ## Examples

      iex> can_user_review_restaurant?(scope, restaurant_id)
      true

  """
  def can_user_review_restaurant?(%Scope{} = scope, restaurant_id) do
    # Verificar si ya tiene una reseña
    existing_review = get_user_restaurant_review(scope, restaurant_id)

    if existing_review do
      false
    else
      # Verificar si ha tenido una reserva confirmada
      query =
        from(res in FoodReserve.Reservations.Reservation,
          where: res.user_id == ^scope.user.id,
          where: res.restaurant_id == ^restaurant_id,
          where: res.status == "confirmed"
        )

      Repo.exists?(query)
    end
  end
end
