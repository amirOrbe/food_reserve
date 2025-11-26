defmodule FoodReserve.Repo.Migrations.AddUserIdToOrders do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :user_id, references(:users, on_delete: :nothing)
    end

    create index(:orders, [:user_id])
  end
end
