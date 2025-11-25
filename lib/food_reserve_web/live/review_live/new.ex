defmodule FoodReserveWeb.ReviewLive.New do
  use FoodReserveWeb, :live_view
  import FoodReserveWeb.LiveHelpers

  alias FoodReserve.Reviews
  alias FoodReserve.Reviews.Review
  alias FoodReserve.Restaurants

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app
      flash={@flash}
      current_scope={@current_scope}
      unread_notifications_count={@unread_notifications_count}
    >
      <div class="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <!-- Header -->
        <div class="bg-white shadow-sm rounded-lg border border-gray-200 mb-6">
          <div class="px-6 py-8 sm:px-8">
            <div class="flex items-center justify-between mb-4">
              <div>
                <h1 class="text-3xl font-bold text-gray-900 mb-2">
                  Calificar Restaurante
                </h1>
                <p class="text-gray-600">
                  Comparte tu experiencia en <span class="font-medium">{@restaurant.name}</span>
                </p>
              </div>
            </div>

            <div class="flex gap-3">
              <.link
                navigate={~p"/restaurants/#{@restaurant}"}
                class="inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-lg text-gray-700 bg-white hover:bg-gray-50"
              >
                <.icon name="hero-arrow-left" class="w-4 h-4 mr-2" /> Volver al Restaurante
              </.link>
            </div>
          </div>
        </div>
        
    <!-- Formulario de Reseña -->
        <div class="bg-white shadow-sm rounded-lg border border-gray-200">
          <div class="px-6 py-8 sm:px-8">
            <.form for={@form} id="review-form" phx-submit="save">
              <div class="space-y-6">
                <!-- Calificación de Comida -->
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-3">
                    Calificación de la Comida
                  </label>
                  <div class="flex items-center space-x-2">
                    <%= for rating <- 1..5 do %>
                      <button
                        type="button"
                        phx-click="set_food_rating"
                        phx-value-rating={rating}
                        class={[
                          "w-8 h-8 rounded-full border-2 transition-colors duration-200",
                          if(@food_rating >= rating,
                            do: "bg-yellow-400 border-yellow-400 text-white",
                            else: "border-gray-300 text-gray-400 hover:border-yellow-400"
                          )
                        ]}
                      >
                        <.icon name="hero-star" class="w-5 h-5 mx-auto" />
                      </button>
                    <% end %>
                    <span class="ml-3 text-sm text-gray-600">
                      <%= if @food_rating > 0 do %>
                        {@food_rating}/5 estrellas
                      <% else %>
                        Selecciona una calificación
                      <% end %>
                    </span>
                  </div>
                  <input type="hidden" name={@form[:food_rating].name} value={@food_rating} />
                </div>
                
    <!-- Calificación de Servicio -->
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-3">
                    Calificación del Servicio
                  </label>
                  <div class="flex items-center space-x-2">
                    <%= for rating <- 1..5 do %>
                      <button
                        type="button"
                        phx-click="set_service_rating"
                        phx-value-rating={rating}
                        class={[
                          "w-8 h-8 rounded-full border-2 transition-colors duration-200",
                          if(@service_rating >= rating,
                            do: "bg-blue-400 border-blue-400 text-white",
                            else: "border-gray-300 text-gray-400 hover:border-blue-400"
                          )
                        ]}
                      >
                        <.icon name="hero-star" class="w-5 h-5 mx-auto" />
                      </button>
                    <% end %>
                    <span class="ml-3 text-sm text-gray-600">
                      <%= if @service_rating > 0 do %>
                        {@service_rating}/5 estrellas
                      <% else %>
                        Selecciona una calificación
                      <% end %>
                    </span>
                  </div>
                  <input type="hidden" name={@form[:service_rating].name} value={@service_rating} />
                </div>
                
    <!-- Comentario -->
                <div>
                  <.input
                    field={@form[:comment]}
                    type="textarea"
                    label="Comentario (opcional)"
                    placeholder="Cuéntanos sobre tu experiencia..."
                    rows="4"
                  />
                </div>
                
    <!-- Promedio General -->
                <%= if @food_rating > 0 and @service_rating > 0 do %>
                  <div class="bg-gray-50 rounded-lg p-4">
                    <div class="flex items-center justify-between">
                      <span class="text-sm font-medium text-gray-700">Calificación General:</span>
                      <div class="flex items-center">
                        <span class="text-lg font-bold text-gray-900 mr-2">
                          {Float.round((@food_rating + @service_rating) / 2, 1)}
                        </span>
                        <div class="flex">
                          <%= for i <- 1..5 do %>
                            <.icon
                              name="hero-star"
                              class={
                                Enum.join(
                                  [
                                    "w-5 h-5",
                                    if(i <= (@food_rating + @service_rating) / 2,
                                      do: "text-yellow-400",
                                      else: "text-gray-300"
                                    )
                                  ],
                                  " "
                                )
                              }
                            />
                          <% end %>
                        </div>
                      </div>
                    </div>
                  </div>
                <% end %>
                
    <!-- Botones -->
                <div class="flex justify-end space-x-3 pt-6 border-t border-gray-200">
                  <.link
                    navigate={~p"/restaurants/#{@restaurant}"}
                    class="px-4 py-2 border border-gray-300 text-sm font-medium rounded-lg text-gray-700 bg-white hover:bg-gray-50"
                  >
                    Cancelar
                  </.link>
                  <button
                    type="submit"
                    disabled={@food_rating == 0 or @service_rating == 0}
                    class={[
                      "px-4 py-2 text-sm font-medium rounded-lg",
                      if(@food_rating > 0 and @service_rating > 0,
                        do: "text-white bg-orange-600 hover:bg-orange-700",
                        else: "text-gray-400 bg-gray-200 cursor-not-allowed"
                      )
                    ]}
                  >
                    Publicar Reseña
                  </button>
                </div>
              </div>
            </.form>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"restaurant_id" => restaurant_id}, _session, socket) do
    restaurant = Restaurants.get_public_restaurant!(restaurant_id)

    # Verificar si el usuario puede dejar una reseña
    can_review = Reviews.can_user_review_restaurant?(socket.assigns.current_scope, restaurant_id)

    if not can_review do
      {:ok,
       socket
       |> put_flash(
         :error,
         "No puedes calificar este restaurante. Necesitas tener una reserva confirmada y no haber calificado antes."
       )
       |> push_navigate(to: ~p"/restaurants/#{restaurant}")}
    else
      changeset = Reviews.change_review(%Review{})

      {:ok,
       socket
       |> assign(:page_title, "Calificar #{restaurant.name}")
       |> assign(:restaurant, restaurant)
       |> assign(:form, to_form(changeset))
       |> assign(:food_rating, 0)
       |> assign(:service_rating, 0)}
    end
  end

  @impl true
  def handle_event("set_food_rating", %{"rating" => rating}, socket) do
    rating = String.to_integer(rating)
    {:noreply, assign(socket, :food_rating, rating)}
  end

  @impl true
  def handle_event("set_service_rating", %{"rating" => rating}, socket) do
    rating = String.to_integer(rating)
    {:noreply, assign(socket, :service_rating, rating)}
  end

  @impl true
  def handle_event("save", %{"review" => review_params}, socket) do
    review_params =
      review_params
      |> Map.put("restaurant_id", socket.assigns.restaurant.id)
      |> Map.put("food_rating", socket.assigns.food_rating)
      |> Map.put("service_rating", socket.assigns.service_rating)

    case Reviews.create_review(socket.assigns.current_scope, review_params) do
      {:ok, _review} ->
        {:noreply,
         socket
         |> put_flash(:info, "¡Gracias por tu reseña! Ha sido publicada exitosamente.")
         |> push_navigate(to: ~p"/restaurants/#{socket.assigns.restaurant}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  # Handle real-time notifications
  handle_notifications()
end
