defmodule FoodReserve.Repo.Migrations.AddNameAndPhoneToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :name, :string
      add :phone_number, :string
    end
  end
end
