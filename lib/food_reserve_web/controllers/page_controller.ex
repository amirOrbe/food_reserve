defmodule FoodReserveWeb.PageController do
  use FoodReserveWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
