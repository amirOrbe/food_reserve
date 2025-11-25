defmodule FoodReserve.Repo.Migrations.AddCategoryAndAvailableToMenuItems do
  use Ecto.Migration

  def change do
    alter table(:menu_items) do
      add :category, :string
      add :available, :boolean, default: true
    end
  end
end
