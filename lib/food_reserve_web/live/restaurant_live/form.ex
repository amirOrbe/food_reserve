defmodule FoodReserveWeb.RestaurantLive.Form do
  use FoodReserveWeb, :live_view

  alias FoodReserve.Restaurants
  alias FoodReserve.Restaurants.Restaurant

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage restaurant records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="restaurant-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="textarea" label="Description" />
        <.input field={@form[:address]} type="text" label="Address" />
        <.input field={@form[:phone_number]} type="text" label="Phone number" />
        <.input field={@form[:cuisine_type]} type="text" label="Cuisine type" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Restaurant</.button>
          <.button navigate={return_path(@current_scope, @return_to, @restaurant)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    restaurant = Restaurants.get_restaurant!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Restaurant")
    |> assign(:restaurant, restaurant)
    |> assign(:form, to_form(Restaurants.change_restaurant(socket.assigns.current_scope, restaurant)))
  end

  defp apply_action(socket, :new, _params) do
    restaurant = %Restaurant{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "New Restaurant")
    |> assign(:restaurant, restaurant)
    |> assign(:form, to_form(Restaurants.change_restaurant(socket.assigns.current_scope, restaurant)))
  end

  @impl true
  def handle_event("validate", %{"restaurant" => restaurant_params}, socket) do
    changeset = Restaurants.change_restaurant(socket.assigns.current_scope, socket.assigns.restaurant, restaurant_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"restaurant" => restaurant_params}, socket) do
    save_restaurant(socket, socket.assigns.live_action, restaurant_params)
  end

  defp save_restaurant(socket, :edit, restaurant_params) do
    case Restaurants.update_restaurant(socket.assigns.current_scope, socket.assigns.restaurant, restaurant_params) do
      {:ok, restaurant} ->
        {:noreply,
         socket
         |> put_flash(:info, "Restaurant updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, restaurant)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_restaurant(socket, :new, restaurant_params) do
    case Restaurants.create_restaurant(socket.assigns.current_scope, restaurant_params) do
      {:ok, restaurant} ->
        {:noreply,
         socket
         |> put_flash(:info, "Restaurant created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, restaurant)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _restaurant), do: ~p"/restaurants"
  defp return_path(_scope, "show", restaurant), do: ~p"/restaurants/#{restaurant}"
end
