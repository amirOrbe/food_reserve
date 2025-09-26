defmodule FoodReserve.Repo.Migrations.CreateMenuItems do
  use Ecto.Migration

  def change do
    create table(:menu_items) do
      add :name, :string
      add :description, :text
      add :price, :decimal
      add :menu_id, references(:menus, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:menu_items, [:menu_id])
  end
end
