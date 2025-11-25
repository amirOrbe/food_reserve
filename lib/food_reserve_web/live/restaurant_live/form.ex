defmodule FoodReserveWeb.RestaurantLive.Form do
  use FoodReserveWeb, :live_view

  alias FoodReserve.Restaurants
  alias FoodReserve.Restaurants.Restaurant

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div class="bg-white shadow-sm rounded-lg border border-gray-200">
          <div class="px-6 py-8 sm:px-8">
            <div class="mb-8">
              <.header>
                {@page_title}
                <:subtitle>
                  Usa este formulario para gestionar la información de tu restaurante.
                </:subtitle>
              </.header>
            </div>

            <.form
              for={@form}
              id="restaurant-form"
              phx-change="validate"
              phx-submit="save"
              class="space-y-6"
            >
              <div class="grid grid-cols-1 gap-6">
                <.input
                  field={@form[:name]}
                  type="text"
                  label="Nombre del Restaurante"
                  placeholder="Ej: La Cocina de María"
                  class="block w-full rounded-lg border-gray-300 shadow-sm focus:border-orange-500 focus:ring-orange-500"
                />

                <.input
                  field={@form[:description]}
                  type="textarea"
                  label="Descripción"
                  placeholder="Describe tu restaurante, especialidades, ambiente..."
                  rows="4"
                  class="block w-full rounded-lg border-gray-300 shadow-sm focus:border-orange-500 focus:ring-orange-500"
                />

                <.input
                  field={@form[:address]}
                  type="text"
                  label="Dirección Completa"
                  placeholder="Calle, número, colonia, ciudad"
                  class="block w-full rounded-lg border-gray-300 shadow-sm focus:border-orange-500 focus:ring-orange-500"
                />

                <div class="grid grid-cols-1 sm:grid-cols-2 gap-6">
                  <.input
                    field={@form[:phone_number]}
                    type="tel"
                    label="Teléfono"
                    placeholder="(55) 1234-5678"
                    class="block w-full rounded-lg border-gray-300 shadow-sm focus:border-orange-500 focus:ring-orange-500"
                  />

                  <.input
                    field={@form[:cuisine_type]}
                    type="text"
                    label="Tipo de Cocina"
                    placeholder="Ej: Mexicana, Italiana, Asiática"
                    class="block w-full rounded-lg border-gray-300 shadow-sm focus:border-orange-500 focus:ring-orange-500"
                  />
                </div>
              </div>

              <div class="flex flex-col sm:flex-row gap-3 pt-6 border-t border-gray-200">
                <button
                  type="submit"
                  phx-disable-with="Guardando..."
                  class="flex-1 sm:flex-none inline-flex justify-center items-center px-6 py-3 border border-transparent text-base font-medium rounded-lg text-white bg-orange-600 hover:bg-orange-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-orange-500 disabled:opacity-50 disabled:cursor-not-allowed transition-colors duration-200"
                >
                  <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M5 13l4 4L19 7"
                    />
                  </svg>
                  Guardar Restaurante
                </button>

                <.link
                  navigate={return_path(@current_scope, @return_to, @restaurant)}
                  class="flex-1 sm:flex-none inline-flex justify-center items-center px-6 py-3 border border-gray-300 text-base font-medium rounded-lg text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-orange-500 transition-colors duration-200"
                >
                  <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M6 18L18 6M6 6l12 12"
                    />
                  </svg>
                  Cancelar
                </.link>
              </div>
            </.form>
          </div>
        </div>
      </div>
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
    |> assign(:page_title, "Editar Restaurante")
    |> assign(:restaurant, restaurant)
    |> assign(
      :form,
      to_form(Restaurants.change_restaurant(socket.assigns.current_scope, restaurant))
    )
  end

  defp apply_action(socket, :new, _params) do
    restaurant = %Restaurant{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "Nuevo Restaurante")
    |> assign(:restaurant, restaurant)
    |> assign(
      :form,
      to_form(Restaurants.change_restaurant(socket.assigns.current_scope, restaurant))
    )
  end

  @impl true
  def handle_event("validate", %{"restaurant" => restaurant_params}, socket) do
    changeset =
      Restaurants.change_restaurant(
        socket.assigns.current_scope,
        socket.assigns.restaurant,
        restaurant_params
      )

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"restaurant" => restaurant_params}, socket) do
    save_restaurant(socket, socket.assigns.live_action, restaurant_params)
  end

  defp save_restaurant(socket, :edit, restaurant_params) do
    case Restaurants.update_restaurant(
           socket.assigns.current_scope,
           socket.assigns.restaurant,
           restaurant_params
         ) do
      {:ok, restaurant} ->
        {:noreply,
         socket
         |> put_flash(:info, "Restaurante actualizado exitosamente")
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
         |> put_flash(:info, "Restaurante creado exitosamente")
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
