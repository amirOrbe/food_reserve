defmodule FoodReserve.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications) do
      add :title, :string, null: false
      add :message, :text, null: false
      add :type, :string, null: false
      add :read, :boolean, default: false, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :reservation_id, references(:reservations, on_delete: :delete_all), null: true
      add :restaurant_id, references(:restaurants, on_delete: :delete_all), null: true

      timestamps(type: :utc_datetime)
    end

    create index(:notifications, [:user_id])
    create index(:notifications, [:reservation_id])
    create index(:notifications, [:restaurant_id])
    create index(:notifications, [:user_id, :read])
    create index(:notifications, [:type])
  end
end
