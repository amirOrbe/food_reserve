defmodule FoodReserveWeb.RestaurantLive.Show do
  use FoodReserveWeb, :live_view

  alias FoodReserve.Restaurants

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@restaurant.name}
        <:subtitle>Información detallada de tu restaurante.</:subtitle>
        <:actions>
          <.button navigate={~p"/restaurants"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/restaurants/#{@restaurant}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Editar restaurante
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Nombre">{@restaurant.name}</:item>
        <:item title="Descripción">{@restaurant.description}</:item>
        <:item title="Dirección">{@restaurant.address}</:item>
        <:item title="Teléfono">{@restaurant.phone_number}</:item>
        <:item title="Tipo de Cocina">{@restaurant.cuisine_type}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Restaurants.subscribe_restaurants(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Ver Restaurante")
     |> assign(:restaurant, Restaurants.get_restaurant!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %FoodReserve.Restaurants.Restaurant{id: id} = restaurant},
        %{assigns: %{restaurant: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :restaurant, restaurant)}
  end

  def handle_info(
        {:deleted, %FoodReserve.Restaurants.Restaurant{id: id}},
        %{assigns: %{restaurant: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "El restaurante actual fue eliminado.")
     |> push_navigate(to: ~p"/restaurants")}
  end

  def handle_info({type, %FoodReserve.Restaurants.Restaurant{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
