defmodule FoodReserve.Repo.Migrations.CreateRestaurants do
  use Ecto.Migration

  def change do
    create table(:restaurants) do
      add :name, :string
      add :description, :text
      add :address, :string
      add :phone_number, :string
      add :cuisine_type, :string
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:restaurants, [:user_id])
  end
end
