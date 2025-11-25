defmodule FoodReserve.Repo.Migrations.CreateReviews do
  use Ecto.Migration

  def change do
    create table(:reviews) do
      add :food_rating, :integer, null: false
      add :service_rating, :integer, null: false
      add :comment, :text
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :restaurant_id, references(:restaurants, on_delete: :delete_all), null: false
      add :reservation_id, references(:reservations, on_delete: :delete_all), null: true

      timestamps(type: :utc_datetime)
    end

    create index(:reviews, [:user_id])
    create index(:reviews, [:restaurant_id])
    create index(:reviews, [:reservation_id])

    create unique_index(:reviews, [:user_id, :restaurant_id],
             name: :reviews_user_restaurant_unique
           )
  end
end
