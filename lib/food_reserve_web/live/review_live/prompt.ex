defmodule FoodReserveWeb.ReviewLive.Prompt do
  use FoodReserveWeb, :live_view
  import FoodReserveWeb.LiveHelpers

  alias FoodReserve.Reservations
  alias FoodReserve.Reviews

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app
      flash={@flash}
      current_scope={@current_scope}
      unread_notifications_count={@unread_notifications_count}
    >
      <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <!-- Header -->
        <div class="bg-white shadow-sm rounded-lg border border-gray-200 mb-6">
          <div class="px-6 py-8 sm:px-8">
            <div class="flex items-center justify-between mb-4">
              <div>
                <h1 class="text-3xl font-bold text-gray-900 mb-2">
                  ¿Cómo fue tu experiencia?
                </h1>
                <p class="text-gray-600">
                  Ayudanos a mejorar compartiendo tu experiencia en
                  <span class="font-medium">{@reservation.restaurant.name}</span>
                </p>
              </div>
              <div class="hidden sm:block">
                <img src={~p"/images/review-illustration.svg"} alt="Review" class="h-24 w-24" />
              </div>
            </div>
          </div>
        </div>
        
    <!-- Main Content -->
        <div class="bg-white shadow-sm rounded-lg border border-gray-200">
          <div class="px-6 py-8 sm:px-8">
            <div class="flex items-start mb-8">
              <.icon name="hero-information-circle" class="w-6 h-6 text-blue-500 mr-4 mt-1" />
              <div>
                <h3 class="font-semibold text-gray-900 mb-2">
                  Tu opinión importa
                </h3>
                <p class="text-gray-600">
                  Gracias por visitar <span class="font-medium">{@reservation.restaurant.name}</span>
                  el <span class="font-medium"><%= Calendar.strftime(@reservation.reservation_date, "%d/%m/%Y") %></span>.
                  Nos encantaría saber lo que pensaste de tu experiencia. Tu feedback nos ayuda a encontrar
                  lugares geniales para comer.
                </p>
              </div>
            </div>
            
    <!-- Options -->
            <div class="space-y-4">
              <%= if @has_reviewed do %>
                <div class="bg-green-50 border border-green-100 rounded-lg p-6 text-center">
                  <.icon name="hero-check-circle" class="w-12 h-12 text-green-500 mx-auto mb-4" />
                  <h3 class="text-lg font-medium text-green-800 mb-2">
                    Ya has calificado este restaurante!
                  </h3>
                  <p class="text-green-600 mb-6">
                    Gracias por compartir tu experiencia con otros usuarios.
                  </p>

                  <div class="flex flex-wrap justify-center gap-4">
                    <.link
                      navigate={~p"/my-reservations"}
                      class="inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-lg text-gray-700 bg-white hover:bg-gray-50"
                    >
                      <.icon name="hero-clipboard-document-list" class="w-4 h-4 mr-2" />
                      View my reservations
                    </.link>
                    <.link
                      navigate={~p"/restaurants/#{@reservation.restaurant_id}"}
                      class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-lg text-white bg-orange-600 hover:bg-orange-700"
                    >
                      <.icon name="hero-arrow-right" class="w-4 h-4 mr-2" /> Ver Restaurante
                    </.link>
                  </div>
                </div>
              <% else %>
                <div class="grid sm:grid-cols-2 gap-4">
                  <div class="bg-orange-50 border border-orange-100 rounded-lg p-6 text-center hover:shadow-md transition-all">
                    <.link
                      navigate={~p"/restaurants/#{@reservation.restaurant_id}/review"}
                      class="block"
                    >
                      <.icon name="hero-star" class="w-12 h-12 text-orange-500 mx-auto mb-4" />
                      <h3 class="text-lg font-medium text-orange-800 mb-2">Deja un review</h3>
                      <p class="text-orange-600 mb-4">
                        Califica la comida y el servicio, y comparte tu experiencia.
                      </p>
                      <span class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-lg text-white bg-orange-600 hover:bg-orange-700">
                        <.icon name="hero-pencil" class="w-4 h-4 mr-2" /> Calificar ahora
                      </span>
                    </.link>
                  </div>

                  <div class="bg-gray-50 border border-gray-200 rounded-lg p-6 text-center hover:shadow-md transition-all">
                    <.link navigate={~p"/my-reservations"} class="block">
                      <.icon name="hero-clock" class="w-12 h-12 text-gray-500 mx-auto mb-4" />
                      <h3 class="text-lg font-medium text-gray-800 mb-2">Calificar más tarde</h3>
                      <p class="text-gray-600 mb-4">
                        Puedes volver más tarde para calificar tu experiencia.
                      </p>
                      <span class="inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-lg text-gray-700 bg-white hover:bg-gray-50">
                        <.icon name="hero-arrow-right" class="w-4 h-4 mr-2" /> Volver a mis reservas
                      </span>
                    </.link>
                  </div>
                </div>
              <% end %>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"reservation_id" => reservation_id}, _session, socket) do
    # Get the reservation with its restaurant
    scope = socket.assigns.current_scope
    reservation = Reservations.get_reservation!(scope, reservation_id, [:restaurant])

    # Verify if the user owns the reservation
    if reservation.user_id != socket.assigns.current_scope.user.id do
      {:ok,
       socket
       |> put_flash(:error, "You don't have permission to view this reservation.")
       |> push_navigate(to: ~p"/my-reservations")}
    else
      # Check if user has already reviewed this restaurant
      has_reviewed =
        Reviews.get_user_restaurant_review(
          socket.assigns.current_scope,
          reservation.restaurant_id
        ) != nil

      {:ok,
       socket
       |> assign(:page_title, "How was your experience?")
       |> assign(:reservation, reservation)
       |> assign(:has_reviewed, has_reviewed)}
    end
  end

  # Handle real-time notifications
  handle_notifications()
end
