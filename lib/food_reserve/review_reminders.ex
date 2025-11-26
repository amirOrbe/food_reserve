defmodule FoodReserve.ReviewReminders do
  @moduledoc """
  Module for handling review reminders.
  """

  alias FoodReserve.Repo
  alias FoodReserve.Reservations.Reservation
  alias FoodReserve.Notifications
  alias FoodReserve.Reviews
  alias FoodReserve.Accounts

  import Ecto.Query

  @hours_after_reservation 2

  @doc """
  Finds reservations that should be marked as completed and sends reminders to leave reviews.
  This function could be called by a scheduled job (when implemented).
  """
  def process_completed_reservations do
    # Get current date and time for comparison
    cutoff_date = Date.utc_today()
    cutoff_time = Time.utc_now()

    # Find reservations that should be marked as completed (past date or current date with time + 2 hours passed)
    query =
      from r in Reservation,
        where:
          r.status == "confirmed" and
            (r.reservation_date < ^cutoff_date or
               (r.reservation_date == ^cutoff_date and
                  fragment(
                    "? < (? + interval '? hours')",
                    r.reservation_time,
                    r.reservation_time,
                    ^@hours_after_reservation
                  ) and
                  fragment(
                    "? < ?",
                    fragment(
                      "? + interval '? hours'",
                      r.reservation_time,
                      ^@hours_after_reservation
                    ),
                    ^cutoff_time
                  ))),
        preload: [:restaurant]

    # Mark as completed and send reminders
    Repo.all(query)
    |> Enum.each(fn reservation ->
      # Check if user has already reviewed this restaurant
      # Create a basic scope with the user for the reviews function
      scope = %Accounts.Scope{user: Repo.get!(Accounts.User, reservation.user_id)}
      has_review = Reviews.get_user_restaurant_review(scope, reservation.restaurant_id) != nil

      # If no review exists, mark as completed and send reminder
      unless has_review do
        {:ok, _updated} =
          FoodReserve.Reservations.update_reservation_status(reservation, "completed")

        Notifications.notify_review_reminder(reservation)
      end
    end)
  end
end
