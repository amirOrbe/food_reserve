defmodule FoodReserve.Repo.Migrations.CreateMenus do
  use Ecto.Migration

  def change do
    create table(:menus) do
      add :name, :string
      add :restaurant_id, references(:restaurants, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:menus, [:restaurant_id])
  end
end
