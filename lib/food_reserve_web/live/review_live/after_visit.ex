defmodule FoodReserveWeb.ReviewLive.AfterVisit do
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
                  How was your experience?
                </h1>
                <p class="text-gray-600">
                  We hope you enjoyed your visit to
                  <span class="font-medium">{@reservation.restaurant.name}</span>
                </p>
              </div>
              <div class="hidden sm:block">
                <img
                  src={~p"/images/review-illustration.svg"}
                  alt="Review"
                  class="h-24 w-24"
                />
              </div>
            </div>
          </div>
        </div>
        
    <!-- Main Content -->
        <div class="bg-white shadow-sm rounded-lg border border-gray-200">
          <div class="px-6 py-8 sm:px-8">
            <div class="flex items-start mb-6">
              <.icon
                name="hero-information-circle"
                class="w-6 h-6 text-blue-500 mr-4 mt-1"
              />
              <div>
                <p class="text-gray-700">
                  Thank you for dining at <strong>{@reservation.restaurant.name}</strong>
                  on <strong><%= format_date(@reservation.reservation_date) %></strong>.
                </p>
                <p class="text-gray-700 mt-2">
                  Would you like to share your experience with other diners?
                </p>
              </div>
            </div>
            
    <!-- Options -->
            <div class="grid sm:grid-cols-2 gap-6">
              <div class="bg-yellow-50 border border-yellow-200 rounded-lg p-6 text-center hover:shadow-md transition duration-200">
                <.link navigate={~p"/restaurants/#{@reservation.restaurant_id}/review"} class="block">
                  <.icon name="hero-star" class="w-12 h-12 text-yellow-500 mx-auto mb-4" />
                  <h3 class="text-lg font-medium text-yellow-800 mb-2">Rate this restaurant</h3>
                  <p class="text-yellow-700 mb-4">
                    Share your opinion about the food, service, and overall experience
                  </p>
                  <span class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-lg text-white bg-yellow-600 hover:bg-yellow-700">
                    <.icon name="hero-pencil-square" class="w-4 h-4 mr-2" /> Write a review
                  </span>
                </.link>
              </div>

              <div class="bg-gray-50 border border-gray-200 rounded-lg p-6 text-center">
                <div class="mb-4">
                  <.icon name="hero-clock" class="w-12 h-12 text-gray-400 mx-auto" />
                </div>
                <h3 class="text-lg font-medium text-gray-700 mb-2">Maybe later</h3>
                <p class="text-gray-600 mb-4">
                  You can always come back and leave a review when you have more time
                </p>
                <div class="mt-2">
                  <.link
                    navigate={~p"/my-reservations"}
                    class="inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-lg text-gray-700 bg-white hover:bg-gray-50"
                  >
                    <.icon name="hero-arrow-left" class="w-4 h-4 mr-2" /> Back to my reservations
                  </.link>
                </div>
              </div>
            </div>
            
    <!-- Reservation details -->
            <div class="mt-8 pt-6 border-t border-gray-200">
              <h4 class="font-medium text-gray-900 mb-3">Reservation Details</h4>
              <div class="bg-gray-50 rounded-lg p-4 grid grid-cols-2 gap-4 text-sm">
                <div>
                  <span class="block text-gray-500">Date</span>
                  <span class="font-medium text-gray-900">
                    {format_date(@reservation.reservation_date)}
                  </span>
                </div>
                <div>
                  <span class="block text-gray-500">Time</span>
                  <span class="font-medium text-gray-900">
                    {format_time(@reservation.reservation_time)}
                  </span>
                </div>
                <div>
                  <span class="block text-gray-500">Party size</span>
                  <span class="font-medium text-gray-900">
                    {@reservation.party_size} people
                  </span>
                </div>
                <div>
                  <span class="block text-gray-500">Reservation status</span>
                  <span class={[
                    "inline-flex items-center px-2 py-1 rounded-full text-xs font-medium",
                    reservation_status_color(@reservation.status)
                  ]}>
                    {String.capitalize(@reservation.status)}
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"reservation_id" => reservation_id}, _session, socket) do
    # Get the reservation with all necessary data
    reservation =
      Reservations.get_reservation!(socket.assigns.current_scope, reservation_id, [:restaurant])

    # Check if the reservation belongs to the current user
    if reservation.user_id != socket.assigns.current_scope.user.id do
      {:ok,
       socket
       |> put_flash(:error, "You don't have permission to view this reservation.")
       |> push_navigate(to: ~p"/my-reservations")}
    else
      # Check if the user has already reviewed this restaurant
      has_reviewed =
        Reviews.get_user_restaurant_review(
          socket.assigns.current_scope,
          reservation.restaurant_id
        ) != nil

      {:ok,
       socket
       |> assign(:page_title, "Review Your Visit")
       |> assign(:reservation, reservation)
       |> assign(:has_reviewed, has_reviewed)}
    end
  end

  # Helper functions
  defp format_date(date) do
    Calendar.strftime(date, "%B %d, %Y")
  end

  defp format_time(time) do
    Calendar.strftime(time, "%H:%M")
  end

  defp reservation_status_color(status) do
    case status do
      "pending" -> "bg-yellow-100 text-yellow-800"
      "confirmed" -> "bg-green-100 text-green-800"
      "completed" -> "bg-blue-100 text-blue-800"
      "cancelled" -> "bg-red-100 text-red-800"
      _ -> "bg-gray-100 text-gray-800"
    end
  end

  # Handle real-time notifications
  handle_notifications()
end
