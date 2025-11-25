defmodule FoodReserve.Repo.Migrations.CreateReservations do
  use Ecto.Migration

  def change do
    create table(:reservations) do
      add :reservation_date, :date
      add :reservation_time, :time
      add :party_size, :integer
      add :status, :string, default: "pending"
      add :special_requests, :text
      add :customer_name, :string
      add :customer_phone, :string
      add :customer_email, :string
      add :user_id, references(:users, on_delete: :delete_all)
      add :restaurant_id, references(:restaurants, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:reservations, [:user_id])
    create index(:reservations, [:restaurant_id])
    create index(:reservations, [:reservation_date])
    create index(:reservations, [:status])
  end
end
