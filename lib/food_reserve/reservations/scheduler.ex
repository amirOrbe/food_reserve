defmodule FoodReserve.Reservations.Scheduler do
  @moduledoc """
  Module for scheduling reservation-related tasks.
  """

  use GenServer
  require Logger

  alias FoodReserve.Reservations

  # Check interval (every 1 hour in milliseconds)
  @check_interval 60 * 60 * 1000

  # Threshold for marking reservations as completed (2 hours after reservation time)
  @completion_threshold_hours 2

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    schedule_next_check()
    {:ok, %{}}
  end

  @impl true
  def handle_info(:check_completed_reservations, state) do
    process_completed_reservations()
    schedule_next_check()
    {:noreply, state}
  end

  defp schedule_next_check do
    Process.send_after(self(), :check_completed_reservations, @check_interval)
  end

  def process_completed_reservations do
    Logger.info("Checking for reservations to mark as completed")

    # Current date and time
    today = Date.utc_today()
    now = Time.utc_now()

    # Get all confirmed reservations for today or past dates
    reservations =
      Reservations.get_reservations_to_complete(today, now, @completion_threshold_hours)

    # Process each reservation
    Enum.each(reservations, fn reservation ->
      Logger.info(
        "Marking reservation ##{reservation.id} as completed and sending review reminder"
      )

      Reservations.complete_reservation_and_notify(reservation.id)
    end)

    Logger.info("Processed #{length(reservations)} reservations")
  end
end
