defmodule FoodReserve.Repo.Migrations.AddActionFieldsToNotifications do
  use Ecto.Migration

  def change do
    alter table(:notifications) do
      add :action_text, :string
      add :action_url, :string
    end
  end
end
