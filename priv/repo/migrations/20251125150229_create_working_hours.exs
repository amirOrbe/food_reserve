defmodule FoodReserve.Repo.Migrations.CreateWorkingHours do
  use Ecto.Migration

  def change do
    create table(:working_hours) do
      add :day_of_week, :string
      add :open_time, :time
      add :close_time, :time
      add :is_closed, :boolean, default: false, null: false
      add :restaurant_id, references(:restaurants, on_delete: :nothing)
      add :user_id, references(:users, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:working_hours, [:user_id])

    create index(:working_hours, [:restaurant_id])
  end
end
